import os
import numpy as np

# first, run everything through R, get stats on each class
def get_stats_for_each_class(folder):
    for fname in os.listdir(folder):
	    # Rscript filename
	    cmd = "Rscript one_class_stats.r " + folder + '/' + fname + ' > output.txt'
	    # execute the command
	    #print(cmd)
	    os.system(cmd)



# now aggregate everything into a spreadsheet
def turn_r_files_to_speadsheet(folder):
    with open('aggregate_data/' + folder + '.csv', 'w') as g:
        print("Year,Semester,Department,Code,num_students,Mean,SD,Kurtosis,Skewness,Dip,p(Dip),Shapiro,p(Shapiro),AD,p(AD),p(BIMT),LR-BIMT,logShap,logpShap", file=g)
        for fname in os.listdir('r_output/' + folder):
            with open('r_output/' + folder + '/' + fname, 'r') as f:
                content = f.readlines()
                year = fname.split('-')[0]
                term = fname.split('-')[1]
                dept = fname.split('-')[2]
                code = fname.split('-')[3].split('.')[0]
                print(year, term, dept, code, sep=',', end=',', file=g)            
                print(*content, sep=',', file=g, end='') #no \n needed at end because python is weird


def analyze_spreadsheet(folder):
    data = np.genfromtxt('aggregate_data/' + folder + '.csv', delimiter=',', skip_header=1)
    p_shapiro = data[:,12]

    # sample size
    n = np.size(p_shapiro)

    # num where we reject null hypothesis
    n_shapiro_rejected = np.size(p_shapiro[p_shapiro < 0.05])
    n_shapiro_fail_to_reject = np.size(p_shapiro[p_shapiro >= 0.05])

    print('Shapiro Wilk: if rejected, is not normally-distributed')
    print(n, 'tested\t', round((n_shapiro_rejected/n)*100,2), '% rejected and are not-normal\t', round((n_shapiro_fail_to_reject/n)*100,), '% fail to reject')

    # now to test bimodality
    kurtosis = data[:, 7]
    p_dip = data[:, 10]

    # kurtosis < 3 is a nec but not suff condit for bimodality
    # see the p values for dip test where kurtosis < 3
    num_kurt = np.size(kurtosis[kurtosis<3])
    med_kurt = np.mean(kurtosis)
    potential_bimod = p_dip[kurtosis<3]
    num_bimod = np.size(potential_bimod[potential_bimod < 0.05])
    print('\nHartigan Dip Test where Kurtosis < 3')
    print(round((num_kurt/n)*100,2), '% have kurtosis < 3\t', round(med_kurt,2), 'mean kurtosis')
    print(num_bimod, 'reject NH (and so are multimodal)\t', round((num_bimod/n)*100, 2), '% of total are multimodal')


if __name__ == '__main__':

    folders = [ 'gaussuniversity', 'twohumpscollege', 'neithertonpolytechnic', 'uoftruncation']
    # If you want to do your own analysis on your own data, create a folder for your data that has the same format
    # as what's in the other folders. Then put the name of your folder in the list folders and take out the other ones.

    for folder in folders:
        print('-----------------------------')
        print('Analysis of', folder, '\n')
        get_stats_for_each_class(folder)
        turn_r_files_to_speadsheet(folder)
        analyze_spreadsheet(folder)
        print('')

