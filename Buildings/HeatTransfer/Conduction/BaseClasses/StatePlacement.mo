within Buildings.HeatTransfer.Conduction.BaseClasses;
model StatePlacement
  "Record that provides the parameters for placing the temperature states near the port_a and port_b"
  // fixme: should this be a record or a model?
  constant Boolean placeStateAtPort_a = false
    "Set to true to place a temperature state at port_a";
  constant Boolean placeStateAtPort_b = false
    "Set to true to place a temperature state at port_b";

  annotation (Diagram(coordinateSystem(preserveAspectRatio=true, extent={{-100,
            -100},{100,100}}), graphics), Icon(coordinateSystem(
          preserveAspectRatio=true, extent={{-100,-100},{100,100}}), graphics),
    Documentation(info="<html>
Record that declares whether a temperature state should be
place at <code>port_a</code> or <code>port_b</code>.
</html>", revisions="<html>
<ul>
<li>
October 12, 2014, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end StatePlacement;
