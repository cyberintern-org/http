const std = @import("std");

pub fn build(b: *std.Build) void {
    // options
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // modules
    const libhttp = b.createModule(.{
        .root_source_file = b.path("lib/http.zig"),
        .target = target,
        .optimize = optimize,
    });
    const liburi = b.createModule(.{
        .root_source_file = b.path("lib/uri.zig"),
        .target = target,
        .optimize = optimize,
    });
    const httpd = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "http", .module = libhttp },
            .{ .name = "uri", .module = liburi },
        },
    });

    // compilation
    b.installArtifact(b.addLibrary(.{
        .linkage = .static,
        .name = "http",
        .root_module = libhttp,
    }));
    b.installArtifact(b.addLibrary(.{
        .linkage = .static,
        .name = "uri",
        .root_module = liburi,
    }));
    const exe = b.addExecutable(.{
        .name = "httpd",
        .root_module = httpd,
    });
    b.installArtifact(exe);

    // build steps
    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    run_cmd.addArgs(b.args orelse &.{});
    run_step.dependOn(&run_cmd.step);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&b.addRunArtifact(b.addTest(.{ .root_module = libhttp })).step);
    test_step.dependOn(&b.addRunArtifact(b.addTest(.{ .root_module = httpd })).step);
}
