#/usr/bin/env python3

import pandas as pd

def dfDiff():
    '''
        计算两个df的差集
    '''
    tt = pd.DataFrame ({'a' : [1,2,3],'b' : [1,2,3],'c' : [1,2,3]})
    tt2 = pd.DataFrame ({'a' : [1,2,4],'b' : [1,2,4],'c' : [1,2,3]})
    
    def ttf(x):
        if tt2[ tt2.a==x.a ].size == 0 :
            print(x.a)
    
    tt3 = tt.apply(ttf,axis=1)
    pass

if __name__ == "__main__":
    df = pd.read_csv("./clearing_bills.csv")
    df = df.iloc[:,[0,2,3,4,8,9,10]]
    df.loc[0]   
