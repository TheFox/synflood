const std = @import("std");

const c_stdlib = @cImport(@cInclude("stdlib.h"));
const c_stdio = @cImport(@cInclude("stdio.h"));
const c_unistd = @cImport(@cInclude("unistd.h"));
const c_libnet = @cImport(@cInclude("libnet.h"));
const getuid = c_unistd.getuid;
const exit = c_stdlib.exit;

pub fn main() !void {
    var stdout = std.io.getStdOut().writer();
    var stderr = std.io.getStdErr().writer();

    try stdout.print("SynFlood 3.0.0-dev.1\n", .{});
    try stdout.print("Copyright (C) 2010 Christian Mayer <http://fox21.at>\n", .{});
    try stdout.print("{s}\n", .{c_libnet.libnet_version()});

    if (getuid() != 0) {
        try stderr.print("ERROR: You are not root, script kiddie.\n", .{});
        exit(1);
    }
}
