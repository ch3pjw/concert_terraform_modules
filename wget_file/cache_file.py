#!/usr/bin/env python3
from functools import partial
import os
import shutil
import sys
import json
from subprocess import call, check_call, check_output, DEVNULL, STDOUT


if __name__ == '__main__':
    query = json.load(sys.stdin)
    url = query['url']
    dest_dir = query['dest_dir']
    file_name = url.replace('/', '_-_')
    dest_path = os.path.join(dest_dir, file_name)

    run = partial(check_call, cwd=dest_dir, stdout=DEVNULL, stderr=STDOUT)

    run(['wget', url, '-O', dest_path])

    print(json.dumps({
        'path': dest_path
    }))
