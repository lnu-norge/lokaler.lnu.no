# Lokaler.lnu.no / app

## Info om prosjektet
[Se i hovedmappen](../)

## Formål med denne biten av kodebasen
`/app` er en fullstack backend og klientside kode for selve lokaler.lnu.no. Den har sin tyngde på frontend, men håndeterer også enkle backend-jobber som `nextjs` kan håndtere. 

Kun unntaktsvis, om det ikke er mulig eller hensiktsmessig å gjøre i `nextjs` skal kode flyttes ut av denne mappen og over i andre undertjenester.

## Kodebasen i /app beskrevet
Dette er en [nextjs](https://nextjs.org/) app.

Den bruker: 
* [nextjs](https://nextjs.org/) / react
* [mobx](https://mobx.js.org/) for state management
* [supabase](https://supabase.io/) for database
* [yjs](https://yjs.dev/) for realtime collaboration
* [ChakraUI](https://chakra-ui.com/) for styling og UI


I [/pages](./pages) finner du alle endepunkter for appen, inkludert api-endepunkter under [/pages/api](./pages/api). 

I [./state](./state) finner du mobx og den globale state managementen.

I [./components](./components) finner du gjenbrukbare react-komponenter som brukes til å lage pagene.
