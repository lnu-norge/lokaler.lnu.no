# Lokaler.lnu.no

## Lisens
Lisens: [AGPL 3.0. Se egen lisensfil](./LICENSE). 

LNU har også (c) på lokaler.lnu.no, og kan velge å dobbelt-lisensiere kildekoden om de ønsker det.

## Bidra gjerne!

Ønsker du å hjelpe til? Les hvordan på [om.lokaler.lnu.no/bidra](https://om.lokaler.lnu.no/bidra/)

PR tas imot med takk.

Bugs rapporteres her i Github som issues.

## Engelsk er arbeidsspråk i koden

I selve kodebasen skal alt være engelsk. Readme.md-filer kan være både norsk og engelsk, etter hva som er hensiktsmessig.

## Hva er Lokaler.lnu.no?

Målet med lokaler.lnu.no er å gjøre det enklere å finne og dele informasjon om lokaler for barne- og ungdomsfrivilligheten.

Lokaler.lnu.no er bygget av [LNU](https://lnu.no). Bygggingen er finansiert av tilskudd fra Bufdir. 

Les gjerne mer om prosjektet på [om.lokaler.lnu.no](https://om.lokaler.lnu.no/)

## Hvordan er kodebasen strukturert?

I `/app` så finner du klient-side-kode basert på `nextjs` (React) og det av backend som kan håndteres av NextJS. Her skjer det meste.

Resten av backend lages som større eller mindre tjenester i `/services`. Foreløpig er denne tom.

Database håndteres av Postgres gjennom [Supabase](https://supabase.io). Vi kommer kanskje til å migrere til å hoste Supabase selv, men foreløpig betaler vi for hosting av databasen og den hostes i Nederland. 

Resten av koden er beskrevet i mer detalj i hver undermappe.