const std = @import("std");

const c_stdlib = @cImport(@cInclude("stdlib.h"));
const c_stdio = @cImport(@cInclude("stdio.h"));
const c_unistd = @cImport(@cInclude("unistd.h"));
const c_libnet = @cImport(@cInclude("libnet.h"));
const getuid = c_unistd.getuid;
const exit = c_stdlib.exit;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var args_iter = try std.process.argsWithAllocator(allocator);
    defer args_iter.deinit();
    _ = args_iter.next();

    var stdout = std.io.getStdOut().writer();
    var stderr = std.io.getStdErr().writer();

    try stdout.print("SynFlood 3.0.0-dev.1\n", .{});
    try stdout.print("Copyright (C) 2010 Christian Mayer <http://fox21.at>\n", .{});
    try stdout.print("{s}\n", .{c_libnet.libnet_version()});

    if (args.len == 1) {
        try print_help();
        return;
    }

    if (getuid() != 0) {
        try stderr.print("ERROR: You are not root, script kiddie.\n", .{});
        exit(1);
    }
}

fn print_help() !void {
    var stdout = std.io.getStdOut().writer();

    const help =
        \\Usage: synflood [-h] -s <IP> -d <IP> -p <PORT> -c <NUM>
        \\
        \\Options:
        \\-h         Print this help.
        \\-s <IP>    Source ip-address.
        \\-d <IP>    Destination ip-address.
        \\-p <PORT>  Destination port.
        \\-c <NUM>   Number of connections.
    ;
    try stdout.print(help ++ "\n", .{});
}
