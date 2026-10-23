const VERSION = "3.2.0-dev.3";
const std = @import("std");
const dprint = std.debug.print;

pub fn build(b: *std.Build) !void {
    const version = try std.SemanticVersion.parse(VERSION);
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .small,
    });

    const target_name = try std.fmt.allocPrint(b.allocator, "synflood-{s}-{s}", .{ @tagName(target.result.cpu.arch), @tagName(target.result.os.tag) });

    dprint("version: {s}\n", .{VERSION});
    dprint("target arch: {s}\n", .{@tagName(target.result.cpu.arch)});
    dprint("target cpu: {s}\n", .{target.result.cpu.model.name});
    dprint("target os: {s}\n", .{@tagName(target.result.os.tag)});
    dprint("target name: {s}\n", .{target_name});
    dprint("optimize: {s}\n", .{@tagName(optimize)});

    const translate_c = b.addTranslateC(.{
        .root_source_file = b.path("src/c.h"),
        .target = target,
        .optimize = optimize,
    });

    const build_options = b.addOptions();
    build_options.addOption([]const u8, "VERSION", VERSION);

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .strip = optimize != .debug,
        .link_libc = true,
        .imports = &.{
            .{
                .name = "c",
                .module = translate_c.createModule(),
            },
        },
    });
    exe_mod.addOptions("build_options", build_options);
    exe_mod.linkSystemLibrary("net", .{});

    const exe = b.addExecutable(.{
        .name = target_name,
        .version = version,
        .root_module = exe_mod,
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    run_cmd.addPassthruArgs();

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
