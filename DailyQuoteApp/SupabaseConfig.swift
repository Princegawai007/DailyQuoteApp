//
//  SupabaseConfig.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 13/01/26.
//

import Foundation
import Supabase

// 1. Your Project URL (I filled this in for you)
let supabaseUrl = URL(string: "https://ennmukyueddpkjtaijyv.supabase.co")!

// 2. Paste the 'anon public' key from the 'Legacy' tab here
let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVubm11a3l1ZWRkcGtqdGFpanl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgyODE4MjksImV4cCI6MjA4Mzg1NzgyOX0.Xm9CTVxkhdaLzdtQMdLjCUC5301JuJEPLEuMVbAsofU"

// 3. Create the global client
let supabase = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)
