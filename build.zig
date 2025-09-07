const std = @import("std");
const print = std.debug.print;
const allocPrint = std.fmt.allocPrint;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall,
    });

    print("target arch: {s}\n", .{@tagName(target.result.cpu.arch)});
    print("target os: {s}\n", .{@tagName(target.result.os.tag)});
    print("optimize: {s}\n", .{@tagName(optimize)});

    const target_name = allocPrint(
        b.allocator,
        "synflood-{s}-{s}",
        .{
            @tagName(target.result.cpu.arch),
            @tagName(target.result.os.tag),
        },
    ) catch @panic("failed to allocate target name");
    print("target name: {s}\n", .{target_name});

    const exe = b.addExecutable(.{
        .name = "synflood",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/synflood.zig"),
            .target = target,
            .optimize = optimize,
            .strip = optimize != .Debug,
            .link_libc = true,
        }),
    });
    exe.linkSystemLibrary("net");
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
