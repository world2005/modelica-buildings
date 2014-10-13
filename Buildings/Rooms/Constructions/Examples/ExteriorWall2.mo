within Buildings.Rooms.Constructions.Examples;
model ExteriorWall2 "Test model for an exterior wall without a window"
  extends Modelica.Icons.Example;

// fixme: Remove this model for the release.

  parameter HeatTransfer.Data.OpaqueConstructions.Insulation100Concrete200 extConMat
    "Record for material layers"
    annotation (Placement(transformation(extent={{-160,60},{-140,80}})));

  parameter Buildings.Rooms.BaseClasses.ParameterConstruction conPar[1](
    each til=Buildings.HeatTransfer.Types.Tilt.Wall,
    each azi=0,
    each A=3*10,
    layers={extConMat}) "Data for construction"
    annotation (Placement(transformation(extent={{-120,60},{-100,80}})));
/* Works
  HeatTransfer.Conduction.MultiLayer opa[1](
    each final layers=extConMat,
    each final A=111,
    each final steadyStateInitial=false,
    each final T_a_start=573.15,
    each final T_b_start=573.15) 
    "Model for heat transfer through opaque construction"
    annotation (Placement(transformation(extent={{16,-34},{46,-4}})));
    */
    // fixme: the assignment below fails with
    // Failed to expand the variable opa[1].lay[1].m
  HeatTransfer.Conduction.MultiLayer opa[1](
    final layers={conPar[1].layers},
    each final A=111,
    each final steadyStateInitial=false,
    each final T_a_start=573.15,
    each final T_b_start=573.15)
    "Model for heat transfer through opaque construction"
    annotation (Placement(transformation(extent={{16,-34},{46,-4}})));

  Buildings.Rooms.BaseClasses.ExteriorBoundaryConditions bouConExt(
    nCon=1,
    linearizeRadiation = false,
    conMod=Buildings.HeatTransfer.Types.ExteriorConvection.TemperatureWind,
    lat=0.73268921998722,
    conPar=conPar)
    "Exterior boundary conditions for constructions without a window"
    annotation (Placement(transformation(extent={{76,-80},{116,-40}})));
  Buildings.HeatTransfer.Sources.PrescribedTemperature prescribedTemperature
    annotation (Placement(transformation(extent={{-120,10},{-100,30}})));
  Buildings.HeatTransfer.Convection.Interior con[
                              1](A={3*10}, til={Buildings.HeatTransfer.Types.Tilt.Wall})
    "Model for heat convection"
    annotation (Placement(transformation(extent={{-20,10},{-40,30}})));
  Modelica.Thermal.HeatTransfer.Components.ThermalCollector theCol(m=1)
    "Thermal collector to link a vector of models to a single model"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-70,20})));
  BoundaryConditions.WeatherData.ReaderTMY3 weaDat(filNam=
        "modelica://Buildings/Resources/weatherdata/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.mos")
    annotation (Placement(transformation(extent={{100,60},{120,80}})));
  Modelica.Blocks.Sources.Constant TRoo(k=273.15 + 20) "Room air temperature"
    annotation (Placement(transformation(extent={{-180,10},{-160,30}})));

equation
  connect(prescribedTemperature.port, theCol.port_b) annotation (Line(
      points={{-100,20},{-90,20},{-90,20},{-80,20}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(theCol.port_a, con.fluid) annotation (Line(
      points={{-60,20},{-50,20},{-50,20},{-40,20}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(weaDat.weaBus, bouConExt.weaBus) annotation (Line(
      points={{120,70},{140,70},{140,-58.6},{110.867,-58.6}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None));
  connect(TRoo.y, prescribedTemperature.T) annotation (Line(
      points={{-159,20},{-122,20}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(opa[1].port_b, bouConExt.opa_a[1]) annotation (Line(
      points={{46,-19},{62,-19},{62,-46.6667},{76,-46.6667}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(opa[1].port_a, con[1].solid) annotation (Line(
      points={{16,-19},{16,20},{-20,20}},
      color={191,0,0},
      smooth=Smooth.None));
  annotation (
experiment(StopTime=1209600),
__Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Rooms/Constructions/Examples/ExteriorWall.mos"
        "Simulate and plot"),
    Diagram(coordinateSystem(preserveAspectRatio=false,extent={{-200,-100},{200,
            100}}), graphics),
    Documentation(info="<html>
<p>
This model tests the exterior construction without windows.
</p>
</html>", revisions="<html>
<ul>
<li>
April 29, 2013, by Michael Wetter:<br/>
Corrected wrong assignment of parameter in instance <code>bouConExt(conMod=...)</code>
which was set to an interior instead of an exterior convection model.
</li>
<li>
May 1, 2013, by Michael Wetter:<br/>
Declared the parameter record to be a parameter, as declaring its elements
to be parameters does not imply that the whole record has the variability of a parameter.
</li>
<li>
March 7, 2012, by Michael Wetter:<br/>
Updated example to use new data model
<a href=\"modelica://Buildings.Rooms.BaseClasses.ParameterConstruction\">
Buildings.Rooms.BaseClasses.ParameterConstruction</a>
in model for boundary conditions.
</li>
<li>
December 6, 2010, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end ExteriorWall2;
