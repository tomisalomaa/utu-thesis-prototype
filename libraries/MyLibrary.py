# Library to support various parsing tasks.
# Each method is usable as a keyword when imported in a Robot file.
# Robot framework logic:
# - Method name translates into a keyword when underscores are left out.
#   For example: def prepare_soup() in this library ==> 'Prepare Soup' in robot file
# - When used as robot keywords after library is imported,
#   keywords require input values unless a default value is declared for an input variable in this library
# - Return in method means the keyword will return content when used
#
# Do note that whenever html parser is used on source content, a lot of syntactic errors present in the
# raw source code will be corrected by the html parses in the process. If the purpose is to receive
# raw content, regular expressions are recommended.

# coding=utf-8
import os
import re
import fnmatch
import shutil
import errno
from bs4 import BeautifulSoup, Doctype

class MyLibrary:
    # While this will be available as a keyword when imported,
    # this is not meant to be used as such.
    # Used as a support method within this class to parse content
    # with Beautiful Soup.
    def prepare_soup(self, src_file, parser):
        '''
        :param src_file: file path
        :param parser: parser to use for parsing content from src_file; current prototype includes support for html5lib and lxml
        '''
        with open(src_file) as src:
            soup = BeautifulSoup(src, parser)
        return soup

    # Searches a given path contents for files matching a given file extension.
    # The path given as input is a starting point, will also search from all sub-directories.
    def search_file_with_extension(self, path, file_extension):
        '''
        Returns all file locations found with specified extension
        from the given path.
        :param path: Path that will be searched within. Must end with '/'.
        :param file_extension: The extension (type) of the file being searched for.
            Must in form without '.' i.e. 'html' or 'css',
            NOT '.html' or '.css'.
        '''
        file_extension = str.lower('*.' + file_extension)
        file_locations = []
        file_location = ''
        for root, dirs, files in os.walk(path, topdown=True):
            for name in files:
                if fnmatch.fnmatch(str.lower(name), file_extension):
                    file_location = os.path.join(root, name)
                    file_locations.append(file_location)
        return file_locations

    # Parses the source contents for all html elements containing the attribute 'id'.
    # Found elements form a bs4 result set (a list) of bs4 tags.
    def find_all_ids_from_html(self, src, parser='html5lib'):
        '''
        :param src: file path
        :param parser: html5lib by default; if provided as input,
                        make sure another parser library is supported.
        '''
        soup = self.prepare_soup(src, parser)
        found_ids = soup.find_all(id=True)
        return found_ids

    # Searches for specific element from the source contents.
    # Search ends as soon as the very first matching instance is found.
    def find_element_from_html(self, src, elem, parser='html5lib'):
        '''
        :param src: file path
        :param parser: html5lib by default; if provided as input,
                        make sure another parser library is supported.
        '''
        soup = self.prepare_soup(src, parser)
        found_element = soup.find(elem)
        return found_element
    
    # See find_element_from_html(); this one does the same but
    # returns all found elements as a list of bs4 tags.
    def find_elements_from_html(self, src, elem, parser='html5lib'):
        '''
        :param src: file path
        :param parser: html5lib by default; if provided as input,
                        make sure another parser library is supported.
        '''
        soup = self.prepare_soup(src, parser)
        found_elements = soup.find_all(elem)
        return found_elements
    
    # Finds elements that have a specific attribute. Attribute values are of no concern.
    # Returns all matching elements as tags.
    def find_elements_with_attribute(self, src, elem_tag, attr, parser='html5lib'):
        '''
        :param src: file path
        :param elem_tag: html element tag to search for, i.e. a, table, li, ul...
        :param attr: attribute the elements should contain, i.e. name, id, class...
        :param parser: html5lib by default; if provided as input,
                        make sure another parser library is supported.
        '''
        soup = self.prepare_soup(src, parser)
        found_elements = soup.find_all(elem_tag, {attr:True})
        return found_elements
    
    # Searches for and lists all child elements of a given bs4 tag.
    def find_immediate_child_elements(self, src):
        '''
        :param src: a bs4 html element tag
        '''
        children = [child for child in src if child.name != None]
        return children

    # Searches for elements that have a given class.
    def find_elements_by_class(self, src, elem, cls, parser='html5lib'):
        '''
        :param src: file path
        :param elem: html element tag to look for
        :param cls: class that element should contain
        '''
        soup = self.prepare_soup(src, parser)
        elems = soup.select(f'{elem}.{cls}')
        return elems

    # Finds elements from source contents. Does not fix the raw content as html parsers do
    # due to not using Beautiful Soup and html parsers.
    # Returns a multi-line string containing child elements from all the found matches.
    def find_elements_from_raw_source(self, src, elem):
        '''
        :param src: file path
        :param elem: element to look for; case is ignored
        '''
        element_results = []
        with open(src) as src_open:
            source_raw = src_open.read()
        regex = rf'(<{elem}.*?>.*?<\/{elem}>)'
        elems = re.findall(regex, source_raw, re.IGNORECASE | re.DOTALL)
        regex_clean_elements = r'<([^\/]\s*[a-zA-Z]*).*?>'
        regex_clean_content = r'>(.*?)<'
        for elem in elems:
            elem = re.sub(regex_clean_elements, r'<\1>', elem, flags=re.IGNORECASE | re.DOTALL)
            elem = re.sub(r'<\s*([aA]).*?>', r'<\1>', elem, flags=re.IGNORECASE | re.DOTALL)
            elem = re.sub(regex_clean_content, '> <', elem, flags=re.IGNORECASE | re.DOTALL)
            element_results.append(elem)
        return element_results

    # Expects a list of elements contained within html ul/ol/menu element.
    # Forms a dictionary based on input list contents so that
    # each key in the dictionary has child elements as values.
    def parent_child_relations_from_list(self, str_list):
        '''
        :param str_list:    a list of elements contained within a single html ul / ol / menu element;
                            elements must be in string format.
                            A proper input can be got from find_elements_from_raw_source(),
                            for example.
        '''
        length = len(str_list)
        parent_child_dict = {}
        met_parents = []
        for i in range(length):
            if str_list[i][1] != '/':
                if i-1 >= 0:
                    if met_parents[0] in parent_child_dict:
                        parent_child_dict[met_parents[0]].append(str_list[i])
                    else:
                        parent_child_dict[met_parents[0]] = [str_list[i]]
                met_parents.insert(0, str_list[i])
            else:
                met_parents.pop(0)
        return parent_child_dict


    def copy_directory_contents(self, src, dst):
        try:
            if os.path.exists(dst):
                shutil.rmtree(dst)
            shutil.copytree(src, dst)
        except OSError as exc:
            if exc.errno in (errno.ENOTDIR, errno.EINVAL):
                shutil.copy(src, dst)
            else:
                raise