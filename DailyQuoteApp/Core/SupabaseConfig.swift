//
//  SupabaseConfig.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 13/01/26.
//

import Foundation
import Supabase


// NOW SAFE: No hardcoded keys here!
let supabase = SupabaseClient(
    supabaseURL: Secrets.supabaseURL,
    supabaseKey: Secrets.supabaseKey
)
// 3. Create the global client
//let supabase = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)
