#!/usr/bin/env python3
from functools import partial
import os
import shutil
import sys
import json
from subprocess import call, check_call, check_output, DEVNULL, STDOUT


def in_output(string, *args, **kwargs):
    return bytes(string, encoding='utf-8') in check_output(*args, **kwargs)


def ensure_repo_exists(run, git_url, path):
    if os.path.exists(path):
        if not in_output(
                git_url, ['git', 'config', 'remote.origin.url'], cwd=path):
            # The remote has changed
            shutil.rmtree(path)
            ensure_repo_exists(run, git_url, path)
    else:
        run(['git', 'clone', git_url, path], cwd=None)


def fetch_if_required(run, path, commit_sha):
    if call(
            ['git', 'show', commit_sha], cwd=path, stdout=DEVNULL,
            stderr=STDOUT):
        run(['git', 'fetch', 'origin'])


def branch_exists(path, branch):
    return in_output(branch, ['git', 'branch', '--list', branch], cwd=path)


def checkout_branch(run, path, branch):
    if branch_exists(path, branch):
        run(['git', 'checkout', branch])
    else:
        run(['git', 'checkout', '-b', branch])


if __name__ == '__main__':
    query = json.load(sys.stdin)
    git_url = query['git_url']
    path = query['clone_path']
    commit_sha = query['commit_sha']
    target_branch = query['target_branch']

    run = partial(check_call, cwd=path, stdout=DEVNULL, stderr=STDOUT)

    ensure_repo_exists(run, git_url, path)
    fetch_if_required(run, path, commit_sha)
    checkout_branch(run, path, target_branch)
    run(['git', 'reset', '--hard', commit_sha])

    print('{}')
