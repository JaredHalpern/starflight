
public class LogPlanetButton : ShipButton
{
	public override string GetLabel()
	{
		return "Log Planet";
	}

	public override bool Execute()
	{
		// get to the player data
		PlayerData playerData = DataController.m_instance.m_playerData;

		if ( playerData.m_starflight.m_location != Starflight.Location.InOrbit )
		{
			SoundController.m_instance.PlaySound( SoundController.Sound.Error );

			m_spaceflightController.m_messages.text = "We're not in orbit.";

			m_spaceflightController.m_buttonController.UpdateButtonSprites();

			return false;
		}

		return false;
	}
}
