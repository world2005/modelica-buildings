within Buildings.Utilities.IO.Python27.Functions.Examples;
model ExchangeFlexLab "Test model for exchange function"
  extends Modelica.Icons.Example;

  Modelica.Blocks.Interfaces.RealOutput  yR1[1] "Real function value";
algorithm
  yR1 := Buildings.Utilities.IO.Python27.Functions.exchange(
   moduleName="testFlexlab",
    functionName="flexlab",
    nDblWri=1,
    nDblRea=1,
    nStrWri=1,
    nStrRea=1,
    strWri={"", "", "u1"},
    strRea={"WattStopper.HS1--4126F--Dimmer Level-2"});

  annotation (
experiment(StopTime=1.0),
__Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Utilities/IO/Python27/Functions/Examples/Exchange.mos"
        "Simulate and plot"),
Documentation(info="<html>
<p>
This example calls various functions in the Python module <code>testFunctions.py</code>.
It tests whether arguments and return values are passed correctly.
The functions in  <code>testFunctions.py</code> are very simple in order to test
whether they compute correctly, and whether the data conversion between Modelica and
Python is implemented correctly.
Each call to Python is followed by an <code>assert</code> statement which terminates
the simulation if the return value is different from the expected value.
</p>
</html>", revisions="<html>
<ul>
<li>
January 31, 2013, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end ExchangeFlexLab;
