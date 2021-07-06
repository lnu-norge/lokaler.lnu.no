import { createClient } from '@supabase/supabase-js'

/** 
 * Supabase Client side client. Meant for use in React.
 * Read full setup on https://supabase.io/docs/reference/javascript/supabase-client
 * */

const {
	NEXT_PUBLIC_SUPABASE_URL, 
	NEXT_PUBLIC_SUPABASE_PUBLIC_KEY 
} = process.env

if (!NEXT_PUBLIC_SUPABASE_URL) {
	throw("Missing supabase env variable NEXT_PUBLIC_SUPABASE_URL")
}

if (!NEXT_PUBLIC_SUPABASE_PUBLIC_KEY) {
	throw("Missing supabase env variable NEXT_PUBLIC_SUPABASE_PUBLIC_KEY")
}

const supabaseClient = createClient(
		process.env.NEXT_PUBLIC_SUPABASE_URL!, 
		process.env.NEXT_PUBLIC_SUPABASE_PUBLIC_KEY!
)

export default supabaseClient