from multiprocessing import Pool
import buildingspy.simulate.Simulator as si 

# Function to set common parameters and to run the simulation
def simulateCase(s):
    s.setStopTime(86400)
    # Kill the process if it does not finish in 1 minute
    s.setTimeOut(60) 
    s.showProgressBar(False)
    s.printModelAndTime()
    s.simulate()
    
def my_range(start, end, step):
    while start <= end:
        yield start
        start += step



# Main function
if __name__ == '__main__':

    # Build list of cases to run
    li = []
    # First model
    model = 'Buildings.Controls.Continuous.Examples.PIDHysteresis'
    
    for x in my_range(0, 3, 0.1):
        s = si.Simulator(model, 'dymola', 'case_' + str(x))
        s.addParameters({'con.eOn': x})
        li.append(s)

    # Run all cases in parallel
    po = Pool()
    po.map(simulateCase, li)