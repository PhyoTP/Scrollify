//
//  File.swift
//  Scrollify
//
//  Created by Phyo Thet Pai on 14/11/25.
//

import Foundation
import FoundationModels
import Playgrounds
@Generable
struct Video: Identifiable, Equatable{
    var id = UUID()
    @Guide(description: "What the creator of the video would put in the caption, one sentence")
    var caption: String
    @Guide(description: "Like the hashtags of a video")
    var tags: [String]
    @Guide(description: "A very short description of the video, eg. A video about...")
    var text: String
    @Guide(description: "A iOS system image that is related to the video, eg. frying.pan")
    var image: String = ""
    @Guide(description: "An emoji that is related to the video")
    var emoji: String = ""
    @Guide(description: "The username of the creator of the video")
    var creator: String
}

//func generateVideo(tags: Set<String>, creators: Set<String>) async throws -> Video {
//    let instructions = """
//    You are a generator that creates a single Swift `Video` struct literal and nothing else.
//
//    REQUIREMENTS:
//    - Output exactly one valid Swift expression of the form:
//      Video(caption: "<caption>", tags: ["tag1","tag2"], text: "<text>", image: "<image>", creator: "<creator>")
//      — including correct quoting, commas, and square brackets. No code fences, no explanation, no extra text, no trailing commas.
//    - All tags must be lowercase, unique, and between 1 and 4 tags total.
//    - caption: short (3–12 words), clickable/social style (question, call-to-action, or emoji allowed).
//    - text: 1 short sentence (5–14 words) describing the video content. (Eg. A video of ...)
//    - image: pick a single icon name (see provided image mapping). Prefer the image mapped to the first chosen tag. If no mapping, use "play.rectangle".
//    - creator: choose either from the followedCreators input (prefer this) or a premade creator. If followedCreators is non-empty, pick from it ~70% of the time; otherwise pick a plausible premade creator.
//    - If likedTags are provided, at least one tag must come from likedTags.
//
//    ADDITIONAL LOGIC (apply in this order):
//    1. Choose tags:
//       - If likedTags provided, choose 1–3 tags from likedTags (randomly) and optionally add 0–1 related tag (from the mapping below) to reach up to 4 tags.
//       - If likedTags is empty, choose 1–4 tags from the premade tags pool below.
//    2. Choose creator:
//       - If followedCreators provided, choose from that list with ~70% probability. With ~30% probability pick a premade creator.
//    3. Choose image:
//       - Use the image mapping for the first chosen tag. If multiple chosen tags have mappings, prefer the first. If none, use "play.rectangle".
//    4. Caption & text:
//       - Caption should reference the main tag or the creator and be eye-catching.
//       - Text should be a concise description matching tags and caption.
//    5. Ensure output matches the `Video(...)` literal exactly.
//
//    Premade tags / creators / image mapping and example videos (use style & tone):
//    - premade tags: ["cat","pets","cute","animals","news","happenings","daily","daily","facts","learning","food","hidden","grwm","beauty","outdoors","fashion","drama","tvshow","movies","entertainment","cooking","recipes","podcast","health","brainrot","memes","funny","skits","workout","fitness","gaming","stream","reaction","edits","cars","dance","football","soccer","sports"]
//    - premade creators: ["cutecats191","daily.news","factsdaily","technews","alexparkman","makeupwithemily","movieclips318","mr.chef176","thehealingpodcast","boomtownmemes","palthecreator","theworkoutboss","streamclips531","unclerobert","footballedits21","madeforspeed","mr.slick63"]
//    - image mapping (tag -> image):
//      cat -> "cat"
//      pets -> "cat"
//      cute -> "face.smiling"
//      animals -> "pawprint"
//      news/happenings -> "newspaper"
//      facts/learning -> "tree"
//      tech -> "globe"
//      food/cooking/recipes -> "frying.pan"
//      hidden/food -> "fork.knife"
//      grwm/beauty/fashion -> "theatermask.and.paintbrush"
//      drama/tvshow/movies/entertainment -> "movieclapper"
//      podcast -> "microphone"
//      brainrot/memes/funny -> "face.smiling"
//      workout/fitness -> "figure.strengthtraining.traditional"
//      gaming/stream -> "headset"
//      reaction -> "person.wave.2"
//      edits/edits-related -> "sparkles"
//      cars -> "car.2"
//      soccer/football/sports -> "soccerball"
//      dance -> "figure.dance"
//      (fallback) -> "play.rectangle"
//
//
//    If the input has no likedTags and no followedCreators, generate a plausible Video using the premade pools above.
//
//    Always respect the literal formatting and field order: caption, tags, text, image, creator.
//
//
//
//
//"""
//    let prompt = "Tags: \(tags.joined(separator: ",")) \nCreators: \(creators.joined(separator: ","))"
//    let session = LanguageModelSession(instructions: instructions)
//    return try await session.respond(to: prompt, generating: Video.self).content
//}
struct Comment{
    var commentor: String
    var comment: String
}
let premadeVideos = [
    Video(caption: "Cats to brighten your day :)", tags: ["cat", "pets", "cute", "animals"], text: "A video of cats", image: "cat",creator: "cutecats191"),
    Video(caption: "A day in the life of a cat", tags: ["daily", "animals", "cute", "cat"], text: "A video of a day in the life of a cat", image: "cat", creator: "cutecats191"),
    Video(caption: "28 y/o man arrested in downtown LA for robbing a bank", tags: ["news", "happenings", "daily"], text: "A news video about a robber", image: "newspaper", creator: "daily.news"),
    Video(caption: "Scientists find a new life-form 10,000 feet in the ocean", tags: ["news", "happenings", "daily","science"], text: "A news video about a science discovery", image: "newspaper", creator: "daily.news"),
    Video(caption: "Did you know that bees were used to make honey 5000 years ago?", tags: ["daily", "facts", "learning","nature"], text: "A video about bee facts", image: "tree", creator: "factsdaily"),
    Video(caption: "What the small bump at the bottom of your TV remote is actually for...", tags: ["daily", "facts", "learning"], text: "A video about a fun fact", image: "brain", creator: "factsdaily"),
    Video(caption: "The history of the internet", tags: ["learning", "facts", "tech"], text: "A video about the history of the internet", image: "globe", creator: "technews"),
    Video(caption: "Lyrch just released the thinnest phone EVER", tags: ["learning", "facts","tech"], text: "A video about a new phone", emoji: "📱", creator: "technews"),
    Video(caption: "Follow me to find this hidden gem in downtown LA!", tags: ["food", "hidden"], text: "A video about an underrated restaurant", image: "fork.knife", creator: "alexparkman"),
    Video(caption: "Why I love Malaysian food...", tags: ["food", "malaysia","travel"], text: "A compilation of food highlights from an overseas trip", image: "fork.knife", creator: "alexparkman"),
    Video(caption: "GRWM to go to the beach!", tags: ["grwm", "beauty", "outdoors", "fashion"], text: "A makeup video", image: "theatermask.and.paintbrush", creator: "makeupwithemily"),
    Video(caption: "The boy found himself in a well", tags: ["drama", "tvshow", "movies","entertainment"], text: "A movie clip", image: "movieclapper", creator: "movieclips318"),
    Video(caption: "The best red curry recipe...", tags: ["cooking","food","recipes"], text: "A cooking video", image: "frying.pan", creator: "mr.chef176"),
    Video(caption: "Doctors don't want you to know this one hack...", tags: ["podcast","health"], text: "A questionable podcast on health tips", image: "microphone", creator: "thehealingpodcast"),
    Video(caption: "new niche number 94, keep ts niche", tags: ["brainrot","memes","funny"], text: "A funny meme video", image: "face.smiling", creator: "boomtownmemes"),
    Video(caption: "So that's why we drive on the left", tags: ["skits","funny","entertainment"], text: "A satirical skit", image: "theatermask.and.paintbrush", creator: "palthecreator"),
    Video(caption: "5 workouts every bodybuilder needs to know", tags: ["workout","fitness","health"], text: "A workout video", image: "figure.strengthtraining.traditional", creator: "theworkoutboss"),
    Video(caption: "Velocity breaks his mic trying to beat this game", tags: ["gaming","stream","funny"], text: "A funny clip of a streamer", image: "headset", creator: "streamclips531"),
    Video(caption: "He put WHAT in his red curry??", tags: ["reaction","cooking","food"], text: "A reaction video to a cooking video", image: "person.wave.2", creator: "unclerobert"),
    Video(caption: "The INSANE goal that put Ressi on the map", tags: ["football","soccer","sports","edits"], text: "A football clip edit", image: "soccerball", creator: "footballedits21"),
    Video(caption: "The car that beat the Viron by 1.2 seconds...", tags: ["edits","cars"], text: "An edit of the fastest car in the world", image: "car.2", creator: "madeforspeed"),
    Video(caption: "Comment down below what dance I should do next!", tags: ["dance","foryou"], text: "A dance video to a pop song", image: "figure.dance", creator: "mr.slick63"),
    Video(caption: "I had to try this dance", tags: ["dance","fyp"], text: "A dance video to a EDM song", image: "figure.dance", creator: "mr.slick63")
]
//#Playground {
//    print("generating...")
//    do{
//        try await print(generateVideo(likedTags: ["cat","cute","food"], creators: ["cutecats191","alexparkman"], allVideos: premadeVideos))
//    }catch{
//        print("Could not generate:" + error.localizedDescription)
//    }
//}
func feedGenerateVideo(dataManager: DataManager) async throws -> Video {
    var prompt = "You are a short-form content creator. Create a short video."
    var chosenCreator = ""
    var chosenTags = Set<String>()
    var values = [0]
    if dataManager.likedTags.count > 5{
        values.append(1)
    }
    if dataManager.following.count > 5{
        values.append(2)
    }
    let chosenValue = values.randomElement() ?? 0
    switch chosenValue{
    case 2:
        let rand = Bool.random()
        if rand{
            chosenCreator = dataManager.following.randomElement()!
            prompt = creatorGeneratePrompt(for: chosenCreator, allVideos: dataManager.videos)
        }
    case 1:
        chosenTags = [dataManager.likedTags.subtracting(additionalTags).randomElement()!]
        let rand = Bool.random()
        if rand{
            chosenTags.insert(dataManager.likedTags.subtracting(additionalTags).randomElement()!)
        }
        let exampleVideos = dataManager.videos.filter{$0.tags.contains(where: { chosenTags.contains($0) })}
        prompt = "You are a short-form content creator. You are going to make a short video on the topic(s) of: \(chosenTags.joined(separator: ", ")). Here are some examples of videos on these topics: \(exampleVideos) Do not copy the examples exactly, only follow the examples."
    default:
        chosenTags = [tags.subtracting(additionalTags).randomElement()!]
        let rand = Bool.random()
        if rand{
            chosenTags.insert(tags.subtracting(additionalTags).randomElement()!)
        }
        let exampleVideos = dataManager.videos.filter{$0.tags.contains(where: { chosenTags.contains($0) })}
        prompt = "You are a short-form content creator. You are going to make a short video on the topic(s) of: \(chosenTags.joined(separator: ", ")). Here are examples of videos on these topics: \(exampleVideos) Do not copy the examples exactly, only follow the examples."
    }
    
    return try await generateVideo(prompt: prompt, chosenCreator: chosenCreator, chosenTags: chosenTags)
}
let additionalTags = ["fyp","foryou","viral","foryoupage"]
func creatorGeneratePrompt(for creator: String, allVideos: [Video]) -> String{
    let creatorVideos = allVideos.filter{$0.creator == creator}
    return "You are a short-form content creator by the name of \(creator). You are going to make a short video. Here are some videos you have made: \(creatorVideos) Make a video similar to the videos you have been making. Do not make the exact same video."
}
func generateVideo(prompt: String, chosenCreator: String, chosenTags: Set<String>) async throws -> Video{
    let session = LanguageModelSession()
    var generatedVideo = try await session.respond(to: prompt, generating: Video.self).content
    if !chosenCreator.isEmpty{
        generatedVideo.creator = chosenCreator
    }else{
        generatedVideo.tags = Array(chosenTags)
        if chosenTags.count == 1{
            generatedVideo.tags.append(additionalTags.randomElement()!)
        }
        
    }
    return generatedVideo
}
