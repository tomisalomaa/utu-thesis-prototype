# coding=utf-8
import os
import fnmatch

class MyLibrary:
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