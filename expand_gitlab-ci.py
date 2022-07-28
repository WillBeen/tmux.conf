#!python

import os
import yaml
import json
import tempfile
from git import Repo

expanded_file = ".gitlab-ci.yml"
gitlab_url = "https://gitlab-devops.foncia.net"

temp_path = tempfile.TemporaryDirectory()

def get_template_dir(git_project, git_branch):
    template_dir = temp_path.name + "/" + git_project + "/"
    if not os.path.isdir(template_dir) :
        repo_url = gitlab_url + "/" + git_project + ".git"
        repo = Repo.clone_from(repo_url, template_dir)
    else :
        repo = Repo(template_dir)
    repo.git.checkout(git_branch)
    return template_dir

with open(expanded_file, "r") as file :
    gci = yaml.safe_load(file.read())

if "include" in gci :
    includes = gci["include"]

    # replace includes
    for inc in includes :
        template_dir = get_template_dir(inc["project"], inc["ref"])
        with open(template_dir + inc["file"], 'r') as file :
            included = yaml.safe_load(file.read())
            for i in included :
                if i in gci:
                    if isinstance(gci[i], dict) :
                        gci[i].update(included[i])
                    elif isinstance(gci[i], list) :
                        gci[i] += included[i]
                else :
                    gci.update({i : included[i]})
    gci.pop("include")

# replace extends
for item in gci :
    if isinstance(gci[item], dict) :
        if 'extends' in gci[item] :
            gci[item].update(gci[gci[item]['extends']])



# only to solve a bug in yaml module ...
gci = json.dumps(gci, sort_keys=False, indent=2)
gci = json.loads(gci)

with open(expanded_file, 'w') as file :
    file.write(yaml.dump(gci, sort_keys=False, width=float("inf")))
