# frozen_string_literal: true

def create_viken # rubocop:disable Metrics/MethodLength
  how_to_book = '<p>Viken fylkeskommune krever at du annekterer
    et nabofylke før du kan booke.</p>
    <p>Når annekteringen er ferdig, så fyller du ut <a href="#">skjema A-123</a> og
    leverer til statsministerens kontor, så vil bli kontaktet.</p>'

  pricing = "<p>Lokale organisasjoner kan få det gratis.</p>
    <p>Andre må betale for vask og vakthold, etter prislisten:
    <a href='#'>Last ned prisliste for Viken (PDF)</a></p>"

  terms = '<ul>
      <li><a href="#">Vlikår for overnatting i Viken (PDF)</a></li>
      <li><a href="#">Brannrutiner for overnatting i Viken (PDF)</a></li>
      <li><a href="#">Nattevaktskjema for overnatting i Viken (PDF)</a></li>
    </ul>'

  who_can_use = '<p>Alle frivillige organisasjoner
    kan ta kontakt. Barne- og ungdoms- organisasjoner
    og organisasjoner med tilknytning til Viken
     prioriteres.<br /><a href="#">Last ned Vikens
    veileder (PDF)</a></p>'

  SpaceGroup.create(
    title: "Videregående skoler i Viken",
    how_to_book: how_to_book,
    pricing: pricing,
    terms: terms,
    who_can_use: who_can_use
  )
end
