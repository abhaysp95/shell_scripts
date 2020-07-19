#!/usr/bin/env python

'''
A script for bookmarks
'''

import os.path
import sys
import csv


def get_urls(bmark_file):
    '''get the url'''
    if not os.path.isfile(bmark_file):
        raise FileNotFoundError("Bookmark file for qutebrowser not found")
    url_list = list()
    with open(bmark_file, 'r+') as bookmark_file:
        for line in bookmark_file.readlines():
            line = line.strip()
            line = line.split(' ')
            try:
                url_list.append({
                    "URL": line[0],
                    "Title": ' '.join(line[1:])
                })
            except IndexError:
                url_list.append({
                    "URL": line[0],
                    "Title": 'No Title Found'
                })

    return url_list


def write_to_csv(from_file, to_file):
    '''write the dict to csv'''
    print("""
        Updating the global bookmark file
        Please wait...
          """)
    urls = get_urls(from_file)
    # print(urls)
    heading = ["URL", "Title"]
    with open(to_file, 'w+') as csv_file:
        write_url = csv.DictWriter(
            csv_file,
            fieldnames=heading,
            quotechar='"',
            escapechar='\\',
            delimiter=' '
        )
        write_url.writeheader()
        # some problem here
        write_url.writerows(urls)
    print("Update Successful")


def give_url(title, list_of_urls):
    '''return the related url for title'''
    got_url = None
    for url_dict in list_of_urls:
        if title.strip() == url_dict['Title']:
            got_url = url_dict['URL']
            break
    return got_url


def main():
    '''main function'''
    home = os.path.expanduser('~')
    try:
        if sys.argv[1] == "--update":
            write_to_csv(
                home + '/.config/qutebrowser/bookmarks/urls',
                home + '/.config/bookmarks'
            )
        elif sys.argv[1] == "--help" or sys.argv[1] == "-h":
            try:
                if sys.argv[2] == "shell":
                    print("""
Usage: ./bookmarks_gen.sh [mode] [options]

    mode:
        --fzf:          if no mode given or with this provided, opens the title
                        list in fzf
        --rofi:         opens the title list in rofi(useful with key-bindings)

    options:
        -h, --help:     show help
        --get [title]:  open the browser with corresponding title's webpage
        --update:       update the global bookmarks file with qutebrowser's
                        bookmarks
                          """)
            except IndexError:
                print("""
Usage: ./bookmarks_gen.py [arguments]

        -h, --help:     show help
        --update:       update the global bookmarks file with qutebrowser's
                        bookmarks
                """)
        elif sys.argv[1] == "--get":
            try:
                list_of_urls = get_urls(home + '/.config/bookmarks')
                result_url = give_url(sys.argv[2], list_of_urls[1:])
                if result_url is None:
                    print("URL not found in bookmark file")
                else:
                    print(result_url)
            except IndexError:
                print("No Title provided")
    except IndexError:
        print("""
No argument provided
see, python3 bookmarks_gen.py --help
              """)


if __name__ == "__main__":
    main()
