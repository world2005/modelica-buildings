within ;
package QSS
  "This package contains basic model that can be used to build multi storey buildings. The models are based on the BESTEST"
  package Rooms
    model SingleZone
      "Basic test with light-weight construction and free floating temperature"
      extends Modelica.Icons.Example;
      package MediumA = Buildings.Media.GasesConstantDensity.SimpleAir
        "Medium model";
      package MediumHW = Buildings.Media.ConstantPropertyLiquidWater
        "Hot water";
      parameter Modelica.SIunits.Angle S_=
        Buildings.HeatTransfer.Types.Azimuth.S "Azimuth for south walls";
      parameter Modelica.SIunits.Angle E_=
        Buildings.HeatTransfer.Types.Azimuth.E "Azimuth for east walls";
      parameter Modelica.SIunits.Angle W_=
        Buildings.HeatTransfer.Types.Azimuth.W "Azimuth for west walls";
      parameter Modelica.SIunits.Angle N_=
        Buildings.HeatTransfer.Types.Azimuth.N "Azimuth for north walls";
      parameter Modelica.SIunits.Angle C_=
        Buildings.HeatTransfer.Types.Tilt.Ceiling "Tilt for ceiling";
      parameter Modelica.SIunits.Angle F_=
        Buildings.HeatTransfer.Types.Tilt.Floor "Tilt for floor";
      parameter Modelica.SIunits.Angle Z_=
        Buildings.HeatTransfer.Types.Tilt.Wall "Tilt for wall";
      parameter Integer nConExtWin = 1 "Number of constructions with a window";
      parameter Integer nConBou = 1
        "Number of surface that are connected to constructions that are modeled inside the room";
      inner Modelica.Fluid.System system
        annotation (Placement(transformation(extent={{-84,138},{-68,154}})));
      parameter Buildings.HeatTransfer.Data.OpaqueConstructions.Generic conExtWal(
        nLay=3,
        absIR_a=0.9,
        absIR_b=0.9,
        material={wooSid,steFraIns,gypBoa},
        absSol_a=0.78,
        absSol_b=0.92,
        roughness_a=Buildings.HeatTransfer.Types.SurfaceRoughness.Smooth)
        "Exterior wall construction"
        annotation (Placement(transformation(extent={{-17,123},{-3,137}})));
      Buildings.Rooms.MixedAir roo(
        redeclare package Medium = MediumA,
        hRoo=2.7,
        nConExtWin=nConExtWin,
        energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
        AFlo=48,
        nConPar=0,
        linearizeRadiation=false,
        lat=weaDat.lat,
        nPorts=2,
        nConExt=1,
        datConExt(
          layers={conExtWal},
          A={8*2.7},
          til={Z_},
          azi={N_}),
        datConExtWin(
          layers={conExtWal},
          A={8*2.7},
          glaSys={window600},
          wWin={2*3},
          hWin={2},
          fFra={0.001},
          til={Z_},
          azi={S_}),
        nConBou=4,
        nSurBou=0,
        datConBou(
          layers={conCei,conIntWal,conIntWalNoMass,conFlo},
          A={48,6*2.7,6*2.7,48},
          til={C_,Z_,Z_,F_})) "Room model for Case 600"
        annotation (Placement(transformation(extent={{9,83},{39,113}})));
      Modelica.Blocks.Sources.Constant qRadGai_flow(k=120/48)
        "Radiative heat gain"
        annotation (Placement(transformation(extent={{-100,86},{-92,94}})));
      Modelica.Blocks.Routing.Multiplex3 multiplex3_1
        annotation (Placement(transformation(extent={{-40,96},{-32,104}})));
      Modelica.Blocks.Sources.Constant uSha(k=0)
        "Control signal for the shading device"
        annotation (Placement(transformation(extent={{-100,106},{-92,114}})));
      Modelica.Blocks.Routing.Replicator replicator(nout=max(1,nConExtWin))
        annotation (Placement(transformation(extent={{-54,106},{-46,114}})));
      Buildings.Rooms.Examples.BESTEST.Data.Win600
             window600(
        UFra=3,
        haveExteriorShade=false,
        haveInteriorShade=false) "Window"
        annotation (Placement(transformation(extent={{39,141},{53,155}})));
      replaceable parameter
        Buildings.Rooms.Examples.BESTEST.Data.StandardResultsFreeFloating
          staRes(
            minT( Min=-18.8+273.15, Max=-15.6+273.15, Mean=-17.6+273.15),
            maxT( Min=64.9+273.15,  Max=69.5+273.15,  Mean=66.2+273.15),
            meanT(Min=24.2+273.15,  Max=25.9+273.15,  Mean=25.1+273.15))
              constrainedby Modelica.Icons.Record
        "Reference results from ASHRAE/ANSI Standard 140"
        annotation (Placement(transformation(extent={{-63,139},{-49,153}})));
      Buildings.Fluid.Sources.FixedBoundary boundary(
        nPorts=1,
        redeclare package Medium = MediumA,
        T=293.15) "Boundary condition"
        annotation (Placement(transformation(extent={{-26,84},{-16,94}})));
      Modelica.Blocks.Interfaces.RealInput qConGai(start=1e-4)
        annotation (Placement(transformation(extent={{-117,67},{-99,85}})));
      Modelica.Blocks.Sources.Constant qLatGai(k=0.0) "Latent heat gain"
        annotation (Placement(transformation(extent={{-100,56},{-92,64}})));
      Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature
        prescribedTemperature1
        annotation (Placement(transformation(extent={{79,-89},{69,-79}})));
      Modelica.Thermal.HeatTransfer.Sensors.HeatFlowSensor heatFlowSensor
        annotation (Placement(transformation(extent={{40,-90},{52,-78}})));
      Modelica.Blocks.Interfaces.RealInput TCei( start = 293.15)
        annotation (Placement(transformation(extent={{167,-93},{149,-75}})));
      Modelica.Blocks.Interfaces.RealOutput QCei
        annotation (Placement(transformation(extent={{158,-106},{140,-88}})));
      Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature
        prescribedTemperature3
        annotation (Placement(transformation(extent={{81,-37},{71,-27}})));
      Modelica.Thermal.HeatTransfer.Sensors.HeatFlowSensor heatFlowSensor2
        annotation (Placement(transformation(extent={{42,-38},{54,-26}})));
      Modelica.Blocks.Interfaces.RealInput TWalE(start=293.15)
        annotation (Placement(transformation(extent={{167,-41},{149,-23}})));
      Modelica.Blocks.Interfaces.RealOutput QWalE
        annotation (Placement(transformation(extent={{158,-54},{140,-36}})));
      Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature
        prescribedTemperature4
        annotation (Placement(transformation(extent={{81,-7},{71,3}})));
      Modelica.Thermal.HeatTransfer.Sensors.HeatFlowSensor heatFlowSensor3
        annotation (Placement(transformation(extent={{40,64},{52,76}})));
      Modelica.Blocks.Interfaces.RealInput TWalW(start=293.15)
        annotation (Placement(transformation(extent={{167,-11},{149,7}})));
      Modelica.Blocks.Interfaces.RealOutput QWalW
        annotation (Placement(transformation(extent={{158,-26},{140,-8}})));
      Buildings.HeatTransfer.Data.Solids.Generic steFraIns(
        x=0.087,
        k=0.049,
        c=836.8,
        d=265,
        nStaRef=1) "steel frame wall insulation"
        annotation (Placement(transformation(extent={{-38,140},{-24,154}})));
      Buildings.HeatTransfer.Data.Solids.Generic wooSid(
        x=0.01,
        k=0.11,
        c=1210,
        d=511,
        nStaRef=1) "Wood siding"
        annotation (Placement(transformation(extent={{-38,124},{-24,138}})));
      Buildings.HeatTransfer.Data.Solids.Generic gypBoa(
        x=0.0127,
        k=0.16,
        c=830,
        d=784,
        nStaRef=3) "1/2 inch gypsum board"
        annotation (Placement(transformation(extent={{-18,140},{-4,154}})));
      parameter Buildings.HeatTransfer.Data.OpaqueConstructions.Generic conIntWal(
        absIR_a=0.9,
        absIR_b=0.9,
        absSol_b=0.92,
        absSol_a=0.92,
        roughness_a=Buildings.HeatTransfer.Types.SurfaceRoughness.Smooth,
        nLay=2,
        material={insGlaFib,gypBoa}) "Interior wall construction"
        annotation (Placement(transformation(extent={{3,123},{17,137}})));
      Buildings.HeatTransfer.Data.Solids.Generic insGlaFib(
        nStaRef=1,
        k=0.036,
        c=960,
        d=140,
        x=0.05) "3 inch insulation: glass fiber"
        annotation (Placement(transformation(extent={{2,140},{16,154}})));
      Buildings.HeatTransfer.Data.Solids.Generic floCon(
        x=0.1016,
        k=1.311,
        c=836.8,
        d=2240,
        nStaRef=3) "4 inch concrete"
        annotation (Placement(transformation(extent={{20,140},{34,154}})));
      parameter Buildings.HeatTransfer.Data.OpaqueConstructions.Generic conFlo(
        absIR_a=0.9,
        absIR_b=0.9,
        absSol_a=0.7,
        absSol_b=0.7,
        roughness_a=Buildings.HeatTransfer.Types.SurfaceRoughness.Rough,
        nLay=1,
        material={floCon}) "floor construction"
        annotation (Placement(transformation(extent={{23,123},{37,137}})));
      parameter Buildings.HeatTransfer.Data.OpaqueConstructions.Generic conCei(
        absIR_a=0.9,
        absIR_b=0.9,
        absSol_a=0.7,
        absSol_b=0.7,
        roughness_a=Buildings.HeatTransfer.Types.SurfaceRoughness.Rough,
        nLay=2,
        material={insNoMass,floCon}) "floor construction"
        annotation (Placement(transformation(extent={{41,123},{55,137}})));
      Buildings.HeatTransfer.Data.Solids.InsulationBoard insNoMass(x=0.05, d=0,
        nStaRef=1) "3 inch insulation"
        annotation (Placement(transformation(extent={{58,140},{72,154}})));
      Buildings.HeatTransfer.Data.Solids.InsulationBoard insConFlo(d=40, x=0.05)
        "3 inch insulation"
        annotation (Placement(transformation(extent={{76,140},{90,154}})));
      Buildings.HeatTransfer.Data.Solids.Generic insGlaFibNoMass(
        nStaRef=1,
        k=0.036,
        c=960,
        d=0,
        x=0.05) "3 inch insulation: glass fiber"
        annotation (Placement(transformation(extent={{92,140},{106,154}})));
      parameter Buildings.HeatTransfer.Data.OpaqueConstructions.Generic conIntWalNoMass(
        absIR_a=0.9,
        absIR_b=0.9,
        absSol_b=0.92,
        absSol_a=0.92,
        roughness_a=Buildings.HeatTransfer.Types.SurfaceRoughness.Smooth,
        nLay=2,
        material={insGlaFibNoMass,gypBoa}) "Interior wall construction"
        annotation (Placement(transformation(extent={{59,123},{73,137}})));
     Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow3
       annotation (Placement(transformation(extent={{88,54},{72,70}})));
     Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow1
       annotation (Placement(transformation(extent={{88,38},{72,54}})));
     Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow4
       annotation (Placement(transformation(extent={{90,6},{74,22}})));
      Modelica.Blocks.Interfaces.RealInput QWalWIn(start=1.0)
        annotation (Placement(transformation(extent={{167,53},{149,71}})));
      Modelica.Blocks.Interfaces.RealInput QWalEIn(start=1.0)
        annotation (Placement(transformation(extent={{167,37},{149,55}})));
      Modelica.Blocks.Interfaces.RealInput QCeiIn(start=1.0)
        annotation (Placement(transformation(extent={{167,5},{149,23}})));
      Buildings.BoundaryConditions.WeatherData.Bus weaBus
        annotation (Placement(transformation(extent={{90,102},{110,122}})));
      Modelica.Blocks.Interfaces.RealInput TDryBul(start=1.0)
        annotation (Placement(transformation(extent={{169,141},{151,159}})));
      Modelica.Blocks.Interfaces.RealInput HDifHor(start=1.0)
        annotation (Placement(transformation(extent={{169,127},{151,145}})));
      Modelica.Blocks.Interfaces.RealInput TDewPoi(start=1.0)
        annotation (Placement(transformation(extent={{169,113},{151,131}})));
     Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow5
       annotation (Placement(transformation(extent={{-36,20},{-20,36}})));
      Modelica.Blocks.Interfaces.RealInput QRadSla
        "heat transfer rate at the surface of the floor"
        annotation (Placement(transformation(extent={{-120,18},{-100,38}})));
    equation
      connect(qRadGai_flow.y,multiplex3_1. u1[1])  annotation (Line(
          points={{-91.6,90},{-61.8,90},{-61.8,102.8},{-40.8,102.8}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(multiplex3_1.y, roo.qGai_flow) annotation (Line(
          points={{-31.6,100},{-9.2,100},{-9.2,105.5},{3,105.5}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(roo.uSha, replicator.y) annotation (Line(
          points={{7.5,110},{-45.6,110}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(uSha.y, replicator.u) annotation (Line(
          points={{-91.6,110},{-54.8,110}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(boundary.ports[1], roo.ports[1]) annotation (Line(
          points={{-16,89},{12.75,89}},
          color={0,127,255},
          smooth=Smooth.None));
      connect(qConGai, multiplex3_1.u2[1]) annotation (Line(
          points={{-108,76},{-56,76},{-56,100},{-40.8,100}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(qLatGai.y, multiplex3_1.u3[1]) annotation (Line(
          points={{-91.6,60},{-50,60},{-50,97.2},{-40.8,97.2}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(prescribedTemperature1.T,TCei)  annotation (Line(
          points={{80,-84},{158,-84}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(prescribedTemperature1.port,heatFlowSensor. port_b) annotation (
          Line(
          points={{69,-84},{52,-84}},
          color={191,0,0},
          smooth=Smooth.None));
      connect(QCei,heatFlowSensor. Q_flow) annotation (Line(
          points={{149,-97},{46,-97},{46,-90}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(prescribedTemperature3.T, TWalE) annotation (Line(
          points={{82,-32},{158,-32}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(prescribedTemperature3.port, heatFlowSensor2.port_b) annotation (
          Line(
          points={{71,-32},{54,-32}},
          color={191,0,0},
          smooth=Smooth.None));
      connect(QWalE, heatFlowSensor2.Q_flow) annotation (Line(
          points={{149,-45},{48,-45},{48,-38}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(prescribedTemperature4.T, TWalW) annotation (Line(
          points={{82,-2},{158,-2}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(prescribedTemperature4.port, heatFlowSensor3.port_b) annotation (
          Line(
          points={{71,-2},{62,-2},{62,70},{52,70}},
          color={191,0,0},
          smooth=Smooth.None));
      connect(QWalW, heatFlowSensor3.Q_flow) annotation (Line(
          points={{149,-17},{46,-17},{46,64}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(heatFlowSensor2.port_a, roo.surf_conBou[2]) annotation (Line(
          points={{42,-32},{28.5,-32},{28.5,85.8125}},
          color={191,0,0},
          smooth=Smooth.None));
      connect(heatFlowSensor3.port_a, roo.surf_conBou[3]) annotation (Line(
          points={{40,70},{28.5,70},{28.5,86.1875}},
          color={191,0,0},
          smooth=Smooth.None));
      connect(heatFlowSensor.port_a, roo.surf_conBou[1]) annotation (Line(
          points={{40,-84},{28.5,-84},{28.5,85.4375}},
          color={191,0,0},
          smooth=Smooth.None));
      connect(QWalWIn, prescribedHeatFlow3.Q_flow) annotation (Line(
          points={{158,62},{88,62}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(QWalEIn, prescribedHeatFlow1.Q_flow) annotation (Line(
          points={{158,46},{88,46}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(QCeiIn, prescribedHeatFlow4.Q_flow) annotation (Line(
          points={{158,14},{90,14}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(prescribedHeatFlow4.port, roo.surf_conBou[1]) annotation (Line(
          points={{74,14},{28.5,14},{28.5,85.4375}},
          color={191,0,0},
          smooth=Smooth.None));
      connect(prescribedHeatFlow1.port, roo.surf_conBou[2]) annotation (Line(
          points={{72,46},{28.5,46},{28.5,85.8125}},
          color={191,0,0},
          smooth=Smooth.None));
      connect(prescribedHeatFlow3.port, roo.surf_conBou[3]) annotation (Line(
          points={{72,62},{28.5,62},{28.5,86.1875}},
          color={191,0,0},
          smooth=Smooth.None));
      connect(roo.weaBus, weaBus) annotation (Line(
          points={{37.425,111.425},{67.7125,111.425},{67.7125,112},{100,112}},
          color={255,204,51},
          thickness=0.5,
          smooth=Smooth.None));
      connect(TDryBul, weaBus.TDryBul) annotation (Line(
          points={{160,150},{132,150},{132,112},{100,112}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(HDifHor, weaBus.HDifHor) annotation (Line(
          points={{160,136},{132,136},{132,112},{100,112}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(TDewPoi, weaBus.TDewPoi) annotation (Line(
          points={{160,122},{132,122},{132,112},{100,112}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(prescribedHeatFlow5.Q_flow, QRadSla) annotation (Line(
          points={{-36,28},{-110,28}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(prescribedHeatFlow5.port, roo.surf_conBou[4]) annotation (Line(
          points={{-20,28},{28.5,28},{28.5,86.5625}},
          color={191,0,0},
          smooth=Smooth.None));
      annotation (
    experiment(StopTime=3.1536e+07),
    __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Rooms/Examples/BESTEST/Case600FF.mos"
            "Simulate and plot"), Documentation(info="<html>
<p>
This model is used for the test case 600FF of the BESTEST validation suite.
Case 600FF is a light-weight building.
The room temperature is free floating.
</p>
</html>",     revisions="<html>
<ul>
<li>
October 9, 2013, by Michael Wetter:<br/>
Implemented soil properties using a record so that <code>TSol</code> and
<code>TLiq</code> are assigned.
This avoids an error when the model is checked in the pedantic mode.
</li>
<li>
July 15, 2012, by Michael Wetter:<br/>
Added reference results.
Changed implementation to make this model the base class
for all BESTEST cases.
Added computation of hourly and annual averaged room air temperature.
<li>
October 6, 2011, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),
        Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
                {150,160}}),
                graphics),
        Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{
                150,160}})));
    end SingleZone;
  end Rooms;

  package Systems
    model RadSlab "Radiant slab heating system"
      extends Modelica.Icons.Example;
      package MediumA = Buildings.Media.GasesConstantDensity.SimpleAir
        "Medium model";
      package MediumHW = Buildings.Media.ConstantPropertyLiquidWater
        "Hot water";
      parameter Modelica.SIunits.Angle S_=
        Buildings.HeatTransfer.Types.Azimuth.S "Azimuth for south walls";
      parameter Modelica.SIunits.Angle E_=
        Buildings.HeatTransfer.Types.Azimuth.E "Azimuth for east walls";
      parameter Modelica.SIunits.Angle W_=
        Buildings.HeatTransfer.Types.Azimuth.W "Azimuth for west walls";
      parameter Modelica.SIunits.Angle N_=
        Buildings.HeatTransfer.Types.Azimuth.N "Azimuth for north walls";
      parameter Modelica.SIunits.Angle C_=
        Buildings.HeatTransfer.Types.Tilt.Ceiling "Tilt for ceiling";
      parameter Modelica.SIunits.Angle F_=
        Buildings.HeatTransfer.Types.Tilt.Floor "Tilt for floor";
      parameter Modelica.SIunits.Angle Z_=
        Buildings.HeatTransfer.Types.Tilt.Wall "Tilt for wall";
      parameter Integer nConExtWin = 1 "Number of constructions with a window";
      parameter Integer nConBou = 1
        "Number of surface that are connected to constructions that are modeled inside the room";
      inner Modelica.Fluid.System system
        annotation (Placement(transformation(extent={{-84,138},{-68,154}})));
      Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature
        prescribedTemperature2
        annotation (Placement(transformation(extent={{81,-63},{71,-53}})));
      Modelica.Thermal.HeatTransfer.Sensors.HeatFlowSensor heatFlowSensor1
        annotation (Placement(transformation(extent={{40,-64},{52,-52}})));
      Modelica.Blocks.Interfaces.RealInput TBotIn(start=293.15)
        annotation (Placement(transformation(extent={{167,-67},{149,-49}})));
      Modelica.Blocks.Interfaces.RealOutput QBotOut
        annotation (Placement(transformation(extent={{158,-80},{140,-62}})));
      Buildings.HeatTransfer.Data.Solids.Generic floCon(
        x=0.1016,
        k=1.311,
        c=836.8,
        d=2240,
        nStaRef=3) "4 inch concrete"
        annotation (Placement(transformation(extent={{-36,140},{-22,154}})));
      parameter Buildings.HeatTransfer.Data.OpaqueConstructions.Generic conFlo(
        absIR_a=0.9,
        absIR_b=0.9,
        absSol_a=0.7,
        absSol_b=0.7,
        roughness_a=Buildings.HeatTransfer.Types.SurfaceRoughness.Rough,
        nLay=2,
        material={insConFlo,floCon}) "floor construction"
        annotation (Placement(transformation(extent={{13,139},{27,153}})));
      Buildings.Fluid.HeatExchangers.RadiantSlabs.SingleCircuitSlab
        RadiantHeatingSystem(
        sysTyp=Buildings.Fluid.HeatExchangers.RadiantSlabs.BaseClasses.Types.SystemType.Floor,
        disPip=0.15,
        pipe=Buildings.Fluid.Data.Pipes.PEX_DN_10(),
        layers=conFlo,
        m_flow_nominal=0.49,
        redeclare package Medium = MediumHW,
        iLayPip=1,
        A=48)
        annotation (Placement(transformation(extent={{-20,20},{0,40}})));
      Buildings.Fluid.Sources.MassFlowSource_T boundary1(
        nPorts=1,
        redeclare package Medium = MediumHW,
        m_flow=0.49,
        use_m_flow_in=false)
        annotation (Placement(transformation(extent={{-84,20},{-64,40}})));
      Buildings.Fluid.Sources.Boundary_ph bou(redeclare package Medium = MediumHW,
          nPorts=1)
        annotation (Placement(transformation(extent={{-88,-26},{-68,-6}})));
      Buildings.HeatTransfer.Data.Solids.InsulationBoard insConFlo(d=40, x=0.05)
        "3 inch insulation"
        annotation (Placement(transformation(extent={{-12,140},{2,154}})));
     Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow3
       annotation (Placement(transformation(extent={{88,52},{72,68}})));
     Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow2
       annotation (Placement(transformation(extent={{96,12},{80,28}})));
      Modelica.Blocks.Interfaces.RealInput QTopIn(start=1.0)
        annotation (Placement(transformation(extent={{165,51},{147,69}})));
      Modelica.Blocks.Interfaces.RealInput QBotIn(start=1.0)
        annotation (Placement(transformation(extent={{167,11},{149,29}})));
    equation
      connect(prescribedTemperature2.T, TBotIn) annotation (Line(
          points={{82,-58},{158,-58}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(prescribedTemperature2.port, heatFlowSensor1.port_b) annotation (
          Line(
          points={{71,-58},{52,-58}},
          color={191,0,0},
          smooth=Smooth.None));
      connect(QBotOut, heatFlowSensor1.Q_flow) annotation (Line(
          points={{149,-71},{46,-71},{46,-64}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(heatFlowSensor1.port_a, RadiantHeatingSystem.surf_b) annotation (Line(
          points={{40,-58},{-6,-58},{-6,20}},
          color={191,0,0},
          smooth=Smooth.None));
      connect(boundary1.ports[1], RadiantHeatingSystem.port_a) annotation (Line(
          points={{-64,30},{-20,30}},
          color={0,127,255},
          smooth=Smooth.None));
      connect(bou.ports[1], RadiantHeatingSystem.port_b) annotation (Line(
          points={{-68,-16},{20,-16},{20,30},{0,30}},
          color={0,127,255},
          smooth=Smooth.None));
      connect(QTopIn, prescribedHeatFlow3.Q_flow) annotation (Line(
          points={{156,60},{88,60}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(prescribedHeatFlow2.Q_flow,QBotIn)  annotation (Line(
          points={{96,20},{158,20}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(prescribedHeatFlow2.port, RadiantHeatingSystem.surf_b)
        annotation (Line(
          points={{80,20},{-6,20}},
          color={191,0,0},
          smooth=Smooth.None));
      connect(prescribedHeatFlow3.port, RadiantHeatingSystem.surf_a)
        annotation (Line(
          points={{72,60},{-6,60},{-6,40}},
          color={191,0,0},
          smooth=Smooth.None));
      annotation (
    experiment(StopTime=3.1536e+07),
    __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Rooms/Examples/BESTEST/Case600FF.mos"
            "Simulate and plot"), Documentation(info="<html>
<p>
This model is used for the test case 600FF of the BESTEST validation suite.
Case 600FF is a light-weight building.
The room temperature is free floating.
</p>
</html>",     revisions="<html>
<ul>
<li>
October 9, 2013, by Michael Wetter:<br/>
Implemented soil properties using a record so that <code>TSol</code> and
<code>TLiq</code> are assigned.
This avoids an error when the model is checked in the pedantic mode.
</li>
<li>
July 15, 2012, by Michael Wetter:<br/>
Added reference results.
Changed implementation to make this model the base class
for all BESTEST cases.
Added computation of hourly and annual averaged room air temperature.
<li>
October 6, 2011, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),
        Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
                {150,160}}),
                graphics),
        Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{
                150,160}})));
    end RadSlab;
  end Systems;
  annotation (uses(                          Modelica(version="3.2.1"),
        Buildings(version="1.6")));
end QSS;
