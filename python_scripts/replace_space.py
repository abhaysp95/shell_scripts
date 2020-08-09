#!/usr/bin/env python3

'''
replace the spaces with _ in all the files of given directory
'''

import os
import sys


def replace_space_recursive(diris='.'):
    '''replace space with underscore'''
    for content in os.scandir(diris):
        if content.is_dir(follow_symlinks=False):
            replace_space(content.path)
        else:
            base_file_name = os.path.basename(content)
            filename, ext = os.path.splitext(base_file_name)
            filename = filename.replace(' ', '_')
            new_filename = "{}{}".format(filename, ext)
            pfilepath = ('/'.join(ppath for ppath in content.path.split('/')[:-1])) + '/' + new_filename
            os.rename(content.path, pfilepath)
            print(f"{content.path} -> {pfilepath}")

def replace_space(diris='.'):
    try:
        for content in os.scandir(diris):
            if os.path.isfile(content):
                base_file_name = os.path.basename(content)
                filename, ext = os.path.splitext(base_file_name)
                filename = filename.replace(' ', '_')
                new_filename = "{}{}".format(filename, ext)
                pfilepath = ('/'.join(ppath for ppath in content.path.split('/')[:-1])) + '/' + new_filename
                os.rename(content.path, pfilepath)
                print(f"{content.path} -> {pfilepath}")
    except NotADirectoryError:
        print("Directory not Found")
        print("Renaming as file")
        base_file_name = os.path.basename(diris)
        filename, ext = os.path.splitext(base_file_name)
        filename = filename.replace(' ', '_')
        new_filename = "{}{}".format(filename, ext)
        if '/' in diris:
            pfilepath = ('/'.join(ppath for ppath in diris.split('/')[:-1])) + '/' + new_filename
        else:
            pfilepath = new_filename
        os.rename(diris, pfilepath)
        print(f"{diris} -> {pfilepath}")


def show_help():
    print("""
Usage:  ./replace_space.py  [-r]\t[path]
    -r:     recursively replace space from filename to underscore
    -h:     show help

Note:
    You can also just provide file name
    Recursive option will only work if given path is directory
""")


try:
    args=sys.argv[1:]
    if len(args) <= 2:
        options=[x for x in args if x.startswith('-')]
        parameters=[x for x in args if not x.startswith('-')]
        if '-r' in options:
            if len(parameters) == 0:
                replace_space_recursive()
            elif os.path.isdir(''.join(parameters)):
                replace_space_recursive(''.join(parameters))
            else:
                print("recursive option not supported with file as parameter")
                sys.exit(1)
        elif '-h' in options:
            if len(parameters) != 0:
                print("Warning: -h option doesn't need any parameter")
            show_help()
        elif len(options) == 0:
            print("Running non-recursively")
            if len(parameters) == 1:
                replace_space(''.join(parameters))
            else:
                replace_space()
        else:
            print("Provided option is not supported")
            sys.exit(1)
    else:
        print("Unnecessary arguments provided")
        sys.exit(1)
except IndexError as e:
    print(e)
    sys.exit(0)
