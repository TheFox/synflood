const std = @import("std");
const print = std.debug.print;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "synflood",
        .target = target,
        .optimize = optimize,
    });

    exe.addCSourceFiles(.{
        .files = &[_][]const u8{
            "src/synflood.c",
        },
        .language = .c,
    });
    exe.linkLibC();
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
