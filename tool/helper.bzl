# Copyright 2018 The Bazel Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Source:
#   https://github.com/google/bazel_rules_install
#     /blob/6001facc1a96bafed0e414a529b11c1819f0cdbe/installer/def.bzl
def _install_files_depset(default_info):
    direct = []
    transitive = []
    if default_info.files:
        transitive.append(default_info.files)
    if default_info.default_runfiles:
        transitive.append(default_info.default_runfiles.files)
    if default_info.files_to_run and default_info.files_to_run.executable:
        direct = [default_info.files_to_run.executable]
    if direct or transitive:
        return depset(direct = direct, transitive = transitive)
    return None

# Arista code:
get_depset = _install_files_depset
