#
# Cookbook Name:: transcend_slb
# Attributes:: default
#
# Copyright 2012, Transcend Computing, Inc.
#
# Licence Info: TBD
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default["clouds_databag"] = "topstack_clouds"
default["users_databag"] = "topstack_users"

default["topstackdb"]["host"] = "localhost"
default["topstackdb"]["name"] = "msi"
default["topstackdb"]["user"] = "msi"
default["topstackdb"]["password"] = "msiIsCool"
