# School study baseline fmri behavioral analysis (from log)

# Sarah Hennessy, 2020

import os
import sys
import csv
import pandas as pd
import numpy as np
import glob
import math

import warnings
warnings.filterwarnings("ignore")

def score(log, outpath):
    all_folders = glob.glob(log + '/*')

    #all_files = glob.glob(log + '/*/*.txt')
    outfilename = outpath + "/fmri_stop_beh.csv"

    exists = os.path.isfile(outfilename)
    if exists:
        overwrite = input('stop! this file already exists! are you sure you want to overwrite? y or n: ')
        if overwrite == 'n':
            print('ok. quitting now.')
            return
    li = []

#1 music, #2 control
    control = ['203AG', '205SD', '206RP', '207KM', '208BJ', '211MA', '212ZA', '216CB', '218CS', '220JM', '224SM', '231JA', '232AG', '233AS', '234DL', '503JM', '504AD', '505GM', '507LA', '510DC', '514EG', '519YI', '521SG', '526CU', '539IF', '540MM', '546AO', '547BA', '554CT', '555PT', '559NM', '560KS', '561JA', '564LD', '565AZ', '569AM', '571LA', '572BL', '573EP', '574SU', '575CV', '577NM', '578JS', '579WN']
    music = ['201SN', '202JR', '204DL', '209BM', '210DC', '213JB', '214ER', '215BM', '219EM', '226FC', '227KT', '235SM', '237XA', '238AP', '501LD', '502FT', '506FA', '509KL', '513GB', '517GR', '518DH', '522SG', '527RC', '528AE', '529SA', '530PG', '532MN', '541IG', '542JL', '543ZP', '545KL', '548DM', '549BA', '552JG', '553LL', '556GL', '558AM', '562SE', '566EB', '567GO', '570GR', '580KM']


    #create a new dataframe
    colnames = ['id','year','group','stop_accuracy', 'go_accuracy', 'go_RT'] #make columns

    newdf = pd.DataFrame(columns = colnames) #create df

    for folder in all_folders:

        print("Running...: %s" %(folder[-5:]))

        files = glob.glob(folder + '/*.txt')

        id = folder[-5:]

        if id in control:
            group = 'control'
        if id in music:
            group = 'music'



        stop_accuracy_li = []
        go_accuracy_li = []
        go_RT_li = []


        for filename in files:
            data = pd.read_csv(filename,delim_whitespace = True, comment = "#", header = "infer", skip_blank_lines = True, engine = "python")
            idfull = data.record_id[0]
            run = filename[-5]
            print('processing %s run %s' %(id,run))

            if "baseline" in idfull:
                year = 'baseline'
            if "year2" in idfull:
                year = 'year1'
            if "year4" in idfull:
                year = 'year4'

            #print(data)
            #print(data.condition)

            for index, row in data.iterrows():
            #    print(index)

                if row.condition == "stopsignal":
                    stop_accuracy_li.append(row.accuracy)

                elif row.condition == "go":
                    go_accuracy_li.append(row.accuracy)

                    if row.accuracy == 1:
                        go_RT_li.append(row.rt)
                else:
                    continue

                #print(go_accuracy_li[-1:])
                #print(go_RT_li[-1:])

        stop_accuracy = sum(stop_accuracy_li)/len(stop_accuracy_li)
        go_accuracy = sum(go_accuracy_li)/len(go_accuracy_li)
        go_RT = sum(go_RT_li)/len(go_RT_li)

        #
        # print("stop acc for %s is %0.7f" %(id, stop_accuracy))
        #
        # print("go acc for %s is %0.7f" %(id, go_accuracy))
        # print("go rt for %s is %0.7f" %(id, go_RT))
        #

        newdf = newdf.append({'id': id, 'group': group, 'stop_accuracy': stop_accuracy, 'go_accuracy': go_accuracy, 'go_RT': go_RT, 'year':year},ignore_index=True)



    newdf.to_csv(outfilename,index =False)

    print('congrats! you are now done with stop fmri beh scoring.')


if __name__ == '__main__':
    # Map command line arguments to function arguments.
    try:
        score(*sys.argv[1:])
    except:
        print("you have run this incorrectly!To run, type:\n \
        'python3.7 [name of script].py [full path of RAW DATA] [full path of output folder]'")
