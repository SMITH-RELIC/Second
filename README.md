📚 Hyperlocal Second-Hand Textbook Exchange
Smart Matching Platform for Students
📌 Overview
Hyperlocal Second-Hand Textbook Exchange is a mobile-based digital platform that connects students within the same locality, school, or college to buy and sell used textbooks easily.
The platform uses a smart matching algorithm to automatically connect students who need specific books with nearby students who have them available.
Our goal is to make education:
More Affordable
More Sustainable
More Secure
More Convenient
Problem Statement

Students face several challenges every academic year:
Expensive new textbooks.
No organized hyperlocal platform for student-to-student exchange.
Used books go to waste.
No intelligent system to match buyers with sellers.
Lack of trust and safety in peer transactions.

💡 Proposed Solution
We built a hyperlocal mobile application that:
Connects verified students within the same college or locality.
Uses smart filtering and ranking logic.
Matches based on title, edition, subject, and location.
Enables secure in-app chat.
Promotes reuse and reduces textbook waste.

✨ Key Features
Verified student authentication
Add / Search second-hand books
Smart Matching Algorithm
Location-based filtering
Real-time chat between users
Secure and trusted exchange
Smart Matching Logic

The platform implements a weighted scoring algorithm that ranks results based on:
Title similarity
Edition match
Subject match
Distance radius
Same college preference
Optional fuzzy string matching is used to handle variations like:
"Engg Maths"
"Engineering Mathematics"
"Engineering Math"
This ensures accurate and intelligent book matching.

🏗 System Architecture
Frontend (Mobile App)
Flutter
Backend & Database
Supabase
PostgreSQL
Smart Matching Logic
Supabase query filtering
Python (FastAPI) – Optional advanced AI
RapidFuzz (for fuzzy matching)
Location Services
OpenStreetMap
Real-Time Chat
Supabase Realtime
Hosting 
Render 
Railway 

🗄 Database Structure
Users Table
id
name
email
college
verified
latitude
longitude
Books Table
id
title
subject
edition
seller_id
price
latitude
longitude
