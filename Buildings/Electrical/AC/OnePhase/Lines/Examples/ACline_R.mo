within Buildings.Electrical.AC.OnePhase.Lines.Examples;
model ACline_R
  extends Modelica.Icons.Example;
  Sources.FixedVoltage E(      definiteReference=true,
    f=50,
    Phi=0,
    V=220)
    annotation (Placement(transformation(extent={{-100,-10},{-80,10}})));
  Loads.Impedance R1(R=10)
    annotation (Placement(transformation(extent={{0,-10},{20,10}})));
  Loads.Impedance R2(
    R=10)
    annotation (Placement(transformation(extent={{0,-30},{20,-10}})));
  Loads.Impedance R3(
    R=10)
    annotation (Placement(transformation(extent={{0,-62},{20,-42}})));
  Loads.Impedance ShortCircuit(R=0)
    annotation (Placement(transformation(extent={{0,20},{20,40}})));
  TwoPortResistance Rline1(R=10, useHeatPort=false)
    annotation (Placement(transformation(extent={{-40,40},{-20,20}})));
  TwoPortResistance Rline2(R=10)
    annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  TwoPortResistance Rline3(R=5)
    annotation (Placement(transformation(extent={{-60,-30},{-40,-10}})));
  TwoPortResistance Rline4(R=5)
    annotation (Placement(transformation(extent={{-36,-30},{-16,-10}})));
  TwoPortResistance Rline5(R=20)
    annotation (Placement(transformation(extent={{-60,-56},{-40,-36}})));
  TwoPortResistance Rline6(R=20)
    annotation (Placement(transformation(extent={{-60,-70},{-40,-50}})));
equation
  connect(E.terminal, Rline1.terminal_n) annotation (Line(
      points={{-80,0},{-70,0},{-70,30},{-40,30}},
      color={0,120,120},
      smooth=Smooth.None));
  connect(Rline1.terminal_p, ShortCircuit.terminal) annotation (Line(
      points={{-20,30},{0,30}},
      color={0,120,120},
      smooth=Smooth.None));
  connect(E.terminal, Rline2.terminal_n) annotation (Line(
      points={{-80,0},{-60,0}},
      color={0,120,120},
      smooth=Smooth.None));
  connect(Rline2.terminal_p, R1.terminal) annotation (Line(
      points={{-40,0},{0,0}},
      color={0,120,120},
      smooth=Smooth.None));
  connect(E.terminal, Rline3.terminal_n) annotation (Line(
      points={{-80,0},{-70,0},{-70,-20},{-60,-20}},
      color={0,120,120},
      smooth=Smooth.None));
  connect(Rline3.terminal_p, Rline4.terminal_n) annotation (Line(
      points={{-40,-20},{-36,-20}},
      color={0,120,120},
      smooth=Smooth.None));
  connect(Rline4.terminal_p, R2.terminal) annotation (Line(
      points={{-16,-20},{-4.44089e-16,-20}},
      color={0,120,120},
      smooth=Smooth.None));
  connect(E.terminal, Rline5.terminal_n) annotation (Line(
      points={{-80,0},{-70,0},{-70,-46},{-60,-46}},
      color={0,120,120},
      smooth=Smooth.None));
  connect(E.terminal, Rline6.terminal_n) annotation (Line(
      points={{-80,0},{-70,0},{-70,-60},{-60,-60}},
      color={0,120,120},
      smooth=Smooth.None));
  connect(Rline5.terminal_p, R3.terminal) annotation (Line(
      points={{-40,-46},{-20,-46},{-20,-52},{0,-52}},
      color={0,120,120},
      smooth=Smooth.None));
  connect(Rline6.terminal_p, R3.terminal) annotation (Line(
      points={{-40,-60},{-20,-60},{-20,-52},{0,-52}},
      color={0,120,120},
      smooth=Smooth.None));
  annotation (experiment(StopTime=1.0, Tolerance=1e-06),
  Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
                               graphics),
  __Dymola_Commands(file=
          "modelica://Buildings/Resources/Scripts/Dymola/Electrical/AC/OnePhase/Lines/Examples/ACline_R.mos"
        "Simulate and plot"));
end ACline_R;