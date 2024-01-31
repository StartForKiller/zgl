const std = @import("std");


pub const OpenGlVersion = struct {
    major: u32,
    minor: u32,
    es: bool,
};

pub const OpenGlVersionLookupTable = std.ComptimeStringMap
(
    OpenGlVersion,
    .{
        .{ "ES_VERSION_1_0", .{ .major = 1, .minor = 0, .es = true } },
        .{ "ES_VERSION_2_0", .{ .major = 2, .minor = 0, .es = true } },
        .{ "ES_VERSION_3_0", .{ .major = 3, .minor = 0, .es = true } },
        .{ "ES_VERSION_3_1", .{ .major = 3, .minor = 1, .es = true } },
        .{ "ES_VERSION_3_2", .{ .major = 3, .minor = 2, .es = true } },
        .{ "VERSION_1_0", .{ .major = 1, .minor = 0, .es = false } },
        .{ "VERSION_1_1", .{ .major = 1, .minor = 1, .es = false } },
        .{ "VERSION_1_2", .{ .major = 1, .minor = 2, .es = false } },
        .{ "VERSION_1_3", .{ .major = 1, .minor = 3, .es = false } },
        .{ "VERSION_1_4", .{ .major = 1, .minor = 4, .es = false } },
        .{ "VERSION_1_5", .{ .major = 1, .minor = 5, .es = false } },
        .{ "VERSION_2_0", .{ .major = 2, .minor = 0, .es = false } },
        .{ "VERSION_2_1", .{ .major = 2, .minor = 1, .es = false } },
        .{ "VERSION_3_0", .{ .major = 3, .minor = 0, .es = false } },
        .{ "VERSION_3_1", .{ .major = 3, .minor = 1, .es = false } },
        .{ "VERSION_3_2", .{ .major = 3, .minor = 2, .es = false } },
        .{ "VERSION_3_3", .{ .major = 3, .minor = 3, .es = false } },
        .{ "VERSION_4_0", .{ .major = 4, .minor = 0, .es = false } },
        .{ "VERSION_4_1", .{ .major = 4, .minor = 1, .es = false } },
        .{ "VERSION_4_2", .{ .major = 4, .minor = 2, .es = false } },
        .{ "VERSION_4_3", .{ .major = 4, .minor = 3, .es = false } },
        .{ "VERSION_4_4", .{ .major = 4, .minor = 4, .es = false } },
        .{ "VERSION_4_5", .{ .major = 4, .minor = 5, .es = false } },
        .{ "VERSION_4_6", .{ .major = 4, .minor = 6, .es = false } },
    },
);

pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const binding_version = b.option(
        []const u8,
        "binding_version",
        "Sets which version of OpenGL use wish to bind to. default=VERSION_4_5",
    )
        orelse "VERSION_4_5";

    const selected_version = OpenGlVersionLookupTable.get(binding_version)
        orelse return error.UnsupportedOpenGlVersion;

    const zgl = b.addModule("zgl", .{
        .root_source_file = .{ .path = "src/zgl.zig" },
        .target = target,
        .optimize = optimize,
    });
    zgl.addAnonymousImport(
        "binding",
        .{
            .root_source_file = .{
                .path = b.fmt("src/bindings/GL_{s}VERSION_{d}_{d}.zig", .{
                    if (selected_version.es)
                        "ES_"
                    else
                        "",
                    selected_version.major,
                    selected_version.minor,
                })
            }
        }
    );
}
