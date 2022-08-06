# coding=utf-8
import os
import re
import fnmatch
from bs4 import BeautifulSoup, Doctype

class MyLibrary:
    # General support helper method
    def prepare_soup(self, src_file, parser):
        with open(src_file) as src:
            soup = BeautifulSoup(src, parser)
        return soup

    # General support
    def search_file_with_extension(self, path, file_extension):
        '''
        Returns the first file location found with specified extension
        from the given path.
        :param path: Path that will be searched within. Must end with '/'.
        :param file_extension: The extension (type) of the file being searched for.
            Must in form without '.' i.e. 'html' or 'css',
            NOT '.html' or '.css'.
        '''
        file_extension = str.lower('*.' + file_extension)
        file_location = ''
        for root, dirs, files in os.walk(path, topdown=True):
            for name in files:
                if fnmatch.fnmatch(str.lower(name), file_extension):
                    file_location = os.path.join(root, name)
                    break
            if file_location:
                break
        return file_location

    # Parse support - cannot be used in static assessment since BS4 "corrects" mistakes
    def search_doctype_from_html(self, src, parser='html5lib'):
        items = []
        soup = self.prepare_soup(src, parser)
        for item in soup.contents:
            if isinstance(item, Doctype):
                items.append(item)
        return items

    def format_soup_tag_to_string(self, soup):
        string_form = []
        for item in soup:
            string_form.append(str(item))
        return string_form

    # Parse support
    def find_all_ids_from_html(self, src, parser='html5lib'):
        soup = self.prepare_soup(src, parser)
        found_ids = soup.find_all(id=True)
        return found_ids

    # Parse support
    def find_element_from_html(self, src, elem, parser='html5lib'):
        soup = self.prepare_soup(src, parser)
        found_element = soup.find(elem)
        return found_element
    
    # Parse support
    def find_elements_from_html(self, src, elem, parser='html5lib'):
        soup = self.prepare_soup(src, parser)
        found_elements = soup.find_all(elem)
        return found_elements
    
    # Parse support
    def find_elements_with_attribute(self, src, elem_tag, attr, parser='html5lib'):
        soup = self.prepare_soup(src, parser)
        found_elements = soup.find_all(elem_tag, {attr:True})
        return found_elements
    
    # Parse support
    def find_immediate_child_elements(self, src):
        children = [child for child in src if child.name != None]
        return children

    # Parse support
    def find_elements_by_class(self, src, elem, cls, parser='html5lib'):
        soup = self.prepare_soup(src, parser)
        elems = soup.select(f'{elem}.{cls}')
        return elems

    # Parse support
    '''
    Does not fix the raw content as html parsers do;
    performs string searches from raw text source.
    Returns a multi-line string containing child elements
    from all the found matches.
    '''
    def find_elements_from_raw_source(self, src, elem):
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

    # Parse support
    '''
    Does not fix the raw content as html parsers do;
    performs string searches from raw text source.
    '''
    def parent_child_relations_from_list(self, str_list):
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
        print(met_parents)
        print(parent_child_dict)
        return parent_child_dict