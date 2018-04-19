import numpy as np

# Gauss University


def grade_bounding(d):
    '''(np array) -> np array
    All values above 100 are set to 100, all below 0 set to 0.'''
    d[d > 100] = 100 # max grade available is 100
    d[d < 0] = 0 # min grade available is 0
    return d

def normal_to_int(centre, stdev):
    return max(int(np.round(np.random.normal(centre, stdev, 1))), 0)

def normal_to_ints(centre, stdev, size):
    d = np.round(np.random.normal(centre, stdev, size)).astype(int)
    return grade_bounding(d)


def generate_university(folder, coursecode, allyears, courses_taught, terms, gen_function):
    for year in allyears:
        for term in terms:
            for coursenum in courses_taught:
                filename = folder + '/' 
                filename += '-'.join([str(year), str(term), coursecode, str(coursenum)])
                filename += '.csv'
                with open(filename, 'w') as f:
                    print(folder, year, term, coursecode, coursenum, sep=';', file=f)            
                    size = max(normal_to_int(courses_taught[coursenum], 10), 8) # AD test needs n>7    
                    d = gen_function(courses_taught, coursenum, size)
                    print(*list(d), sep='\n', file=f)


def gauss_university_gen(courses_taught, coursenum, size):
    centre = normal_to_int(50, 2)
    stdev = max(0.5, normal_to_int(10, 1))

    d = normal_to_ints(centre, stdev, size)  
    return d              


def gauss_truncated_gen(courses_taught, coursenum, size):
    centre = normal_to_int(80, 2) 
    stdev = max(1, normal_to_int(10, 1))

    d = normal_to_ints(centre, stdev, size)  
    return d              


def twohumps_gen(courses_taught, coursenum, size):
    # size: assume both `humps' are of the same size
    size = max(normal_to_int(courses_taught[coursenum], 20), 8) # AD test needs n>7

    centre1 = min(normal_to_int(85, 2), 90) # median above 90 is unlikely
    stdev1 = max(1, normal_to_int(2, 2))

    centre2 = min(normal_to_int(40, 2), 90) # median above 90 is unlikely
    stdev2 = max(1, normal_to_int(2, 2))

    d1 = normal_to_ints(centre1, stdev1, int(size/2))  
    d2 = normal_to_ints(centre2, stdev2, int(size/2))
    d = np.append(d1, d2)
    return d    


def neither_gen(courses_taught, coursenum, size):
    # both uniform and triangular distribs fail tests of normality
    # uniform gets some false positives on dip test (10%)
    # triangular does not (1%)
    # d = np.random.randint(0, 100, size) --- gets more false positives on dip test
    d = np.random.triangular(0, 100, 100, size)
    return d          



if __name__ == '__main__':
    coursecode = 'CSC'
    allyears = range(2000, 2005)
    courses_taught = {100:500, 101:300, 105:100, 200:200, 201:100, 202:100, 300:60, 301:60, 302:50, 333:60, 400:50} #value is median class size
    terms = [1, 2]

    generate_university('gaussuniversity', coursecode, allyears, courses_taught, terms, gauss_university_gen)

    generate_university('twohumpscollege', coursecode, allyears, courses_taught, terms, twohumps_gen)

    generate_university('neithertonpolytechnic', coursecode, allyears, courses_taught, terms, neither_gen)

    generate_university('uoftruncation', coursecode, allyears, courses_taught, terms, gauss_truncated_gen)
