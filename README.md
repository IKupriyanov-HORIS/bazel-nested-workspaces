# bazel-nested-workspaces


I have a project with nested WORKSPACES. Nested project uses dependencies(`//lib:commons-collections4`) and scripts (`//buils-scripts:module.bzl`) from parent.

Structure:
```
├── BUILD.bazel
├── build-scripts
│   ├── BUILD.bazel
│   └── module.bzl
├── lib
│   ├── BUILD.bazel
│   ├── commons-collections4
│   │   └── BUILD.bazel
│   └── third_party.bzl
├── nested
│   ├── foo
│   │   └── BUILD.bazel
│   ├── lib
│   │   ├── BUILD.bazel
│   │   ├── commons-lang3
│   │   │   └── BUILD.bazel
│   │   └── third_party.bzl
│   └── WORKSPACE
└── WORKSPACE
```

To get access to parent's dependencies and scripts I added parent as local repository.

nested `WORKSPACE`
```
local_repository(
  name="parent",
  path= "..",
)


load("@parent//lib:third_party.bzl", "third_party_libs")
third_party_libs()

load("//lib:third_party.bzl", "nested_third_party_libs")
nested_third_party_libs()
```

nested `BUILD.bazel`

```
load("@parent//build-scripts:module.bzl", "java_library")

java_library(
    name = "foo",
    visibility = ["//visibility:public"],
    deps = [
        "//lib/commons-lang3",
        "@parent//lib/commons-collections4",
    ],
)
```


`bazel build //...` for nested workspace works fine:

```
user:~/Projects/bazel-nested-workspaces$ cd nested
user:~/Projects/bazel-nested-workspaces/nested$ bazel build //...
INFO: Analysed target //lib/commons-lang3:commons-lang3 (9 packages loaded).
INFO: Found 1 target...
Target //lib/commons-lang3:commons-lang3 up-to-date:
  bazel-bin/lib/commons-lang3/libcommons-lang3.jar
INFO: Elapsed time: 9.480s, Critical Path: 3.50s
INFO: Build completed successfully, 5 total actions
```

But when I try to build parent:

```
user:~/Projects/bazel-nested-workspaces/nested$ cd ..
user:~/Projects/bazel-nested-workspaces$ bazel build //...
ERROR: error loading package 'nested/foo': Extension file not found. Unable to load package for '@parent//build-scripts:module.bzl': The repository could not be resolved
ERROR: error loading package 'nested/foo': Extension file not found. Unable to load package for '@parent//build-scripts:module.bzl': The repository could not be resolved
INFO: Elapsed time: 0.147s
FAILED: Build did NOT complete successfully (1 packages loaded)
    currently loading: nested/foo ... (3 packages)

```
I tried different solutions (absolute path for local repository, playing with workind directory), but found that you can just write any statements with incorrect syntax to the nested WORKSPACE file and still get the same error. So looks like the WORKSPACE file is not used. 
