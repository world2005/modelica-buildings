within Buildings.Examples.Tutorial.Boiler;
model System1
  "1st part of the system model, consisting of the room with heat transfer"
  extends Modelica.Icons.Example;
  replaceable package MediumA =
      Buildings.Media.GasesPTDecoupled.MoistAirUnsaturated;

  inner Modelica.Fluid.System system
    annotation (Placement(transformation(extent={{60,-80},{80,-60}})));
  Fluid.MixingVolumes.MixingVolume vol(
    redeclare package Medium = MediumA,
    m_flow_nominal=mA_flow_nominal,
    V=V)
    annotation (Placement(transformation(extent={{60,20},{80,40}})));
  Modelica.Thermal.HeatTransfer.Components.ThermalConductor theCon(G=20000/30)
    "Thermal conductance with the ambient"
    annotation (Placement(transformation(extent={{20,40},{40,60}})));
  parameter Modelica.SIunits.Volume V=6*10*3 "Room volume";
  parameter Modelica.SIunits.MassFlowRate mA_flow_nominal = V*6/3600
    "Nominal mass flow rate";
  parameter Modelica.SIunits.HeatFlowRate QRooInt_flow = 4000
    "Internal heat gains of the room";
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature TOut(T=263.15)
    "Outside temperature"
    annotation (Placement(transformation(extent={{-20,40},{0,60}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow preHea
    "Prescribed heat flow"
    annotation (Placement(transformation(extent={{20,70},{40,90}})));
  Modelica.Thermal.HeatTransfer.Components.HeatCapacitor heaCap(C=2*V*1.2*1006)
    "Heat capacity for furniture and walls"
    annotation (Placement(transformation(extent={{60,50},{80,70}})));
  Modelica.Blocks.Sources.CombiTimeTable timTab(
      extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
      table=[      0, 0;
              8*3600, 0;
              8*3600, QRooInt_flow;
             18*3600, QRooInt_flow;
             18*3600, 0;
             24*3600, 0]) "Time table for internal heat gain"
    annotation (Placement(transformation(extent={{-20,70},{0,90}})));
equation
  connect(TOut.port, theCon.port_a) annotation (Line(
      points={{5.55112e-16,50},{20,50}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(theCon.port_b, vol.heatPort) annotation (Line(
      points={{40,50},{50,50},{50,30},{60,30}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(preHea.port, vol.heatPort) annotation (Line(
      points={{40,80},{50,80},{50,30},{60,30}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(heaCap.port, vol.heatPort) annotation (Line(
      points={{70,50},{50,50},{50,30},{60,30}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(timTab.y[1], preHea.Q_flow) annotation (Line(
      points={{1,80},{20,80}},
      color={0,0,127},
      smooth=Smooth.None));
  annotation (Documentation(info="<html>
<p>
This part of the system model implements the room with a heat gain.
The room is simplified as a volume of air, a prescribed heat source for
the internal convective heat gain, and a heat conductor for steady-state
heat conduction to the outside.
To increase the heat capacity of the room, such as due to heat stored
in furniture and in building constructions, the heat capacity
of the room air was increased by a factor of three.
The convective heat transfer coefficient is lumped into the heat conductor
model.
</p>
<h4>Implementation</h4>
<p>
This section describes step by step how we implemented the model.
</p>
<ol>
<li>
<p>
First, we dragged 
<a href=\"modelica://Modelica.Fluid.System\">
Modelica.Fluid.System</a> into the model and keep its name at
its default setting, which is <code>system</code>.
This model is required for all fluid flow models to set
global properties.
</p>
</li>
<li>
<p>
Next, to define the medium properties, we added the declaration
</p>
<pre>
  replaceable package MediumA =
      Buildings.Media.GasesPTDecoupled.MoistAirUnsaturated;
</pre>
<p>
This will allow the propagation of the medium model to all models that contain air.
In this example, there is only one model with air.
</p>
<p>
We called the medium <code>MediumA</code> to distinguish it from
<code>MediumW</code> that we will use in later versions of the model for components that
have water as a medium. Because we do not anticipate saturated air, we used
the medium model
<a href=\"modelica://Buildings.Media.GasesPTDecoupled.MoistAirUnsaturated\">
Buildings.Media.GasesPTDecoupled.MoistAirUnsaturated</a>
instead of 
<a href=\"modelica://Buildings.Media.GasesPTDecoupled.MoistAir\">
Buildings.Media.GasesPTDecoupled.MoistAir</a>
as the latter is computationally more expensive.
Because in this model, we are not interested in air humidification or
dehumidification, we could have as well used the medium model
<a href=\"modelica://Buildings.Media.GasesPTDecoupled.SimpleAir\">
Buildings.Media.GasesPTDecoupled.SimpleAir</a>.
</p>
<p>
We also defined the system-level parameters
<pre>
  parameter Modelica.SIunits.Volume V=6*10*3 \"Room volume\";
  parameter Modelica.SIunits.MassFlowRate mA_flow_nominal = V*6/3600
    \"Nominal mass flow rate\";
  parameter Modelica.SIunits.HeatFlowRate QRooInt_flow = 4000 
    \"Internal heat gains of the room\";
</pre>
to declare that the room volume is <i>180</i> m<sup>3</sup>, that the room
has a nominal mass flow rate of <i>6</i> air changes per hour and that 
the internal heat gains of the room are <i>4000</i> Watts.
These parameters have been declared at the top-level of the model
as they will be used in several other models.
Declaring them at the top-level allows to propagate them to other
models, and to easily change them at one location should this be required
when revising the model.
</p>
</li>
<li>
<p>
To model the room air, approximated as a completely mixed volume of air, 
an instance of
<a href=\"modelica://Buildings.Fluid.MixingVolumes.MixingVolume\">
Buildings.Fluid.MixingVolumes.MixingVolume</a>
has been used, as this model can be used with dry air or moist air.
The medium model has been set to <code>MediumA</code>, and the nominal mass
flow rate is set to <code>mA_flow_nominal</code>.
The nominal mass flow rate is used for numerical reasons and should be set 
to the approximate order of magnitude. It only has an effect if the mass flow
rate is near zero and what \"near zero\" means depends on the magnitude of
<code>m_flow_nominal</code>, as it is used for the default value of the parameter
<code>m_flow_small</code> on the <code>Assumptions</code> tag of the model.
See also 
<a href=\"modelica://Buildings.Fluid.UsersGuide\">
Buildings.Fluid.UsersGuide</a>
for an explanation of the purpose of <code>m_flow_small</code>.
</p>
</li>
<li>
<p>
Since we need to increase the heat capacity of the room air to approximate
energy storage in furniture and building constructions, we connected the instance
<code>heaCap</code> to the heat port of the room air.
The model <code>heaCap</code> models energy storage. We set its capacity to
<i>C=2*V*1.2*1006</i> J/K. This will increase the total heat capacity 
of the room air by a factor of three.
</p>
</li>
<li>
<p>
We used the instance <code>heaCon</code> to model the heat conductance to the ambient.
Since our room should have a heat loss of <i>20</i> kW at a temperature difference
of <i>30</i> Kelvin, we set the conductance to 
<i>G=20000 &frasl; 30</i> W/K.
</p>
</li>
<li>
<p>
We used the instance <code>preHea</code> to model a prescribed heat gain, 
such as due to internal heat source.
This model outputs the heat gain which is equal to the value of its 
input signal, which is obtained from a time table.
</p>
</li>
<li>
<p>
To define a time-dependent heat gain, we instantiated the block
<a href=\"modelica://Modelica.Blocks.Sources.CombiTimeTable\">
Modelica.Blocks.Sources.CombiTimeTable</a>
and set its name to <code>timTab</code>.
We set the table parameters to
</p>
<pre>
Modelica.Blocks.Sources.CombiTimeTable timTab(
      extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic, 
      table=[      0, 0; 
              8*3600, 0; 
              8*3600, QRooInt_flow; 
             18*3600, QRooInt_flow; 
             18*3600, 0; 
             24*3600, 0]) \"Time table for internal heat gain\";
</pre>
<p>
Note that we configured the parameters in such a way that the output is a periodic signal.
The documentation of <a href=\"modelica://Modelica.Blocks.Sources.CombiTimeTable\">
Modelica.Blocks.Sources.CombiTimeTable</a>
explains why we added two values for 8am and 6pm.
</p>
</li>
<li>
<p>
Next, we connected its output to the input of the instance <code>preHea</code>.
</p>
</li>
</ol>
<p>
This completes the initial version of the model. When simulating the model
for <i>2</i> days, or <i>172800</i> seconds, the
response shown below should be seen.
</p>
<p align=\"center\">
<img src=\"modelica://Buildings/Resources/Images/Examples/Tutorial/Boiler/System1Temperatures.png\" border=\"1\">
</p>
<p>
To verify the correctness of the model, we can compare the simulated results to the
following analytical solutions:
</p>
<p>
<ol>
<li>
<p>
When the internal heat gain is zero, the room temperature should be equal 
to the outside temperature.
</p>
</li>
<li>
<p>
At steady-state when the internal heat gain is <i>4000</i> Watts,
the temperature difference to the outside should be
<i>&Delta; T = Q&#775; &frasl; UA = 4000/(20000/30) = 6</i> Kelvin, which 
corresponds to a room temperature of <i>-4</i>&deg;C.
</p>
</li>
</ol>
</p>
<p>
Both analytical values agree with the simulation results shown in the above figure.
</p>
<p>
An alternative validation can be done by fixing the temperature of the volume to
<i>20</i>&deg;C and plotting the heat flow rate that is needed to maintain
this temperature.
This can be implemented by connecting an instance of
<a href=\"modelica://Modelica.Thermal.HeatTransfer.Sources.FixedTemperature\">
Modelica.Thermal.HeatTransfer.Sources.FixedTemperature</a>
as shown below.
<p align=\"center\">
<img src=\"modelica://Buildings/Resources/Images/Examples/Tutorial/Boiler/System1PrescribedTemperature.png\" border=\"1\">
</p>
<p>
When plotting the heat flow rate <code>fixTemp.port.Q_flow</code>, one can see
that the required heat flow rate to keep the temperature at 
<i>20</i>&deg;C is 
<i>20</i> kW during night, and 
<i>16</i> kW during day when the heat gain is active.
</p>
<!-- Notes -->
<h4>Notes</h4>
<p>
For a more realistic model of a room, the model 
<a href=\"modelica://Buildings.Rooms.MixedAir\">
Buildings.Rooms.MixedAir</a>
could have been used.
For transient heat conduction, models from the
package
<a href=\"modelica://Buildings.HeatTransfer.Conduction\">
Buildings.HeatTransfer.Conduction</a>
could have been used.
</p>
</html>", revisions="<html>
<ul>
<li>
January 27, 2012, by Michael Wetter:<br>
First implementation.
</li>
</ul>
</html>"),
    Diagram(graphics),
    Commands(file=
     "modelica://Buildings/Resources/Scripts/Dymola/Examples/Tutorial/Boiler/System1.mos"
        "Simulate and plot"),
    experiment(StopTime=172800));
end System1;