# Add necessary imports
import os
import re
import pandas as pd
import matplotlib.pyplot as plt

# ------------------- #

REPO_PATH = os.path.dirname(os.path.abspath(__file__+ '/..')) + '/'
IMAGES_PATH = REPO_PATH + 'images/'

# ------------------- #

plt.style.use('seaborn-v0_8-deep')


#######################
#                     #
#      UTILITIES      #
#                     #
#######################

# Specify the paths of the files
names_file_path = REPO_PATH + 'test/binaries_list.txt'
sizes_file_path = REPO_PATH + 'test/text_sizes.txt'

# Create an empty dictionary
size_dict = {}

# Read the names file and sizes file
with open(names_file_path, 'r') as names_file, open(sizes_file_path, 'r') as sizes_file:
    # Read lines from both files
    names = names_file.read().splitlines()
    sizes = sizes_file.read().splitlines()

    size_dict = {name.split('/')[1].strip(): int(size) for name, size in zip(names, sizes)}

# Extract some extra information
def extract_info(row):
    binary = row['binary']
    # Compiler
    row['compiler'] = re.search(r'-(.+?)-', binary).group(1)
    # Version
    row['version'] = re.search(r'-(\d+\.*\d*)-', binary).group(1)
    # Optimization
    row['O'] = re.search(r'-O([0123s])_', binary).group(1)
    # Name
    row['name'] = re.search(r'_(.+)', binary).group(1)
    # Accuracy
    row['acc'] = row['found_count']/(row['found_count']+row['not_found_count'])
    # Size
    row['size'] = size_dict[row['binary']]
    # Weight
    row['weight'] = 1-(row['false_positives']*5)/row['size']
    return row

def hist_by_compiler(df, is_raw=False, is_nm=False):
    archs = df['arch'].unique()
    for a in archs:
        df_a = df[df['arch'] == a]
        df_a_clang = df_a[df_a['compiler'] == 'clang']
        df_a_gcc = df_a[df_a['compiler'] == 'gcc']
        # Create a histogram
        plt.figure(figsize=(7,4))
        plt.hist([df_a_clang['acc']*df_a_clang['weight'], df_a_gcc['acc']*df_a_gcc['weight']], bins=30, label=['clang', 'gcc'])
        # Set labels and title
        plt.xlabel('Accuracy')
        plt.ylabel('Frequency')
        plt.legend(loc='upper left')
        extra = ' (raw)' if is_raw else ''
        plt.title(f'Accuracy by compiler for {a}{extra}')
        name = 'raw_compiler_' if is_raw else 'results_compiler_'
        nm = '_nm' if is_nm else ''
        plt.savefig(IMAGES_PATH + name + a + nm + '.png')

def hist_by_optimization(df, is_raw=False, is_nm=False):
    archs = df['arch'].unique()
    for a in archs:
        df_a = df[df['arch'] == a]
        df_a_0 = df_a[df_a['O'] == '0']
        df_a_12 = df_a[df_a['O'] == ('1' or '2')]
        df_a_3 = df_a[df_a['O'] == '3']
        df_a_s = df_a[df_a['O'] == 's']
        df_a_0 = df_a_0['acc']*df_a_0['weight']
        df_a_12 = df_a_12['acc']*df_a_12['weight']
        df_a_3 = df_a_3['acc']*df_a_3['weight']
        df_a_s = df_a_s['acc']*df_a_s['weight'] 
        # Create a histogram
        plt.figure(figsize=(10,4))
        plt.hist([df_a_0, df_a_12, df_a_3, df_a_s], bins=30, label=['0','1-2','3','s'])
        # Set labels and title
        plt.xlabel('Accuracy')
        plt.ylabel('Frequency')
        plt.legend(loc='upper left')
        extra = ' (raw)' if is_raw else ''
        plt.title(f'Accuracy by optimization for {a}{extra}')
        name = 'raw_O_' if is_raw else 'results_O_'
        nm = '_nm' if is_nm else ''
        plt.savefig(IMAGES_PATH + name + a + nm + '.png')


#######################
#                     #
#       CLASSIC       #
#                     #
#######################

# Load files
res = pd.read_csv(REPO_PATH + 'test/results.csv')
raw = pd.read_csv(REPO_PATH + 'test/results_raw.csv')

res = res.apply(extract_info, axis=1)
raw = raw.apply(extract_info, axis=1)

res = res[res['tested'] == 'yes']
raw = raw[raw['tested'] == 'yes']

hist_by_compiler(res)
hist_by_compiler(raw, is_raw=True)

hist_by_optimization(res)
hist_by_optimization(raw, is_raw=True)

#######################
#                     #
#   NM GROUND TRUTH   #
#                     #
#######################

# Load files
res = pd.read_csv(REPO_PATH + 'test/results_nm.csv')
raw = pd.read_csv(REPO_PATH + 'test/results_raw_nm.csv')

res = res.apply(extract_info, axis=1)
raw = raw.apply(extract_info, axis=1)

res = res[res['tested'] == 'yes']
raw = raw[raw['tested'] == 'yes']

hist_by_compiler(res, is_nm=True)
hist_by_compiler(raw, is_nm=True, is_raw=True)

hist_by_optimization(res, is_nm=True)
hist_by_optimization(raw, is_nm=True, is_raw=True)