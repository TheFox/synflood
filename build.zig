const std = @import("std");
const print = std.debug.print;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exez = b.addExecutable(.{
        .name = "synfloodz",
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/synflood.zig"),
    });
    exez.linkSystemLibrary("net");
    b.installArtifact(exez);

    // const exec = b.addExecutable(.{
    //     .name = "synfloodc",
    //     .target = target,
    //     .optimize = optimize,
    // });

    // exec.addCSourceFiles(.{
    //     .files = &[_][]const u8{
    //         "src/synflood.c",
    //     },
    //     .language = .c,
    // });
    // exec.linkLibC();
    // exec.linkSystemLibrary("net");

    // b.installArtifact(exec);

    // const run_cmd = b.addRunArtifact(exec);
    // run_cmd.step.dependOn(b.getInstallStep());

    // if (b.args) |args| {
    //     run_cmd.addArgs(args);
    // }

    // const run_step = b.step("run", "Run the app");
    // run_step.dependOn(&run_cmd.step);
}
