const std = @import("std");
const print = std.debug.print;

pub fn build(b: *std.Build) !void {
    const version: std.SemanticVersion = .{ // VERSION
        .major = 3,
        .minor = 2,
        .patch = 0,
        .pre = "dev.1",
    };
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall,
    });

    const target_name = try std.fmt.allocPrint(b.allocator, "synflood-{s}-{s}", .{ @tagName(target.result.cpu.arch), @tagName(target.result.os.tag) });

    print("target arch: {s}\n", .{@tagName(target.result.cpu.arch)});
    print("target cpu: {s}\n", .{target.result.cpu.model.name});
    print("target os: {s}\n", .{@tagName(target.result.os.tag)});
    print("target name: {s}\n", .{target_name});
    print("optimize: {s}\n", .{@tagName(optimize)});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/synflood.zig"),
        .target = target,
        .optimize = optimize,
        .strip = optimize != .Debug,
        .link_libc = true,
    });
    exe_mod.linkSystemLibrary("net", .{});

    const exe = b.addExecutable(.{
        .name = target_name,
        .version = version,
        .root_module = exe_mod,
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
