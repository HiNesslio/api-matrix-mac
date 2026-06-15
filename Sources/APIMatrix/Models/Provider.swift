import Foundation

enum ProviderCategory: String, CaseIterable, Codable {
    case all = "All"
    case llm = "LLM"
    case cloud = "Cloud"
    case image = "Image / Video"
    case other = "Other"
}

struct ProviderGroup: Identifiable {
    let id: ProviderCategory
    let providers: [ProviderDef]
}

struct ProviderDef: Identifiable, Hashable {
    let id: String
    let name: String
    let category: ProviderCategory
    let symbolName: String

    init(id: String, name: String, category: ProviderCategory, symbolName: String? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.symbolName = symbolName ?? Self.defaultSymbol(for: id)
    }

    static func defaultSymbol(for id: String) -> String {
        switch id {
        case "openai": return "sparkle"
        case "anthropic": return "brain.head.profile"
        case "deepseek": return "magnifyingglass.circle"
        case "google-gemini": return "leaf"
        case "meta-llama": return "pyramid"
        case "mistral": return "wind"
        case "groq": return "bolt.fill"
        case "cohere": return "dot.scope"
        case "perplexity": return "magnifyingglass"
        case "xai-grok": return "xmark"
        case "openrouter": return "arrow.triangle.branch"
        case "together": return "square.grid.3x3.fill"
        case "qwen": return "c.square.fill"
        case "minimax": return "square.grid.2x2"
        case "kimi": return "textformat.size"
        case "mimo": return "face.dashed"
        case "elevenlabs": return "waveform"
        case "stability": return "paintpalette"
        case "replicate": return "arrow.triangle.2.circlepath"
        case "runway": return "video.fill"
        case "fal": return "camera.filters"
        case "fireworks": return "flame"
        case "suno": return "music.note"
        case "udio": return "music.note.list"
        case "huggingface": return "face.smiling"
        case "azure-openai": return "cloud"
        case "aws-bedrock": return "cloud.fill"
        case "cloudflare": return "cloud.bolt.fill"
        case "deepinfra": return "square.stack.3d.up.fill"
        case "nebius": return "star.circle"
        case "coze": return "bubble.left.and.bubble.right"
        case "dify": return "square.grid.3x1.folder.badge.plus"
        case "hyperbolic": return "circle.hexagongrid"
        case "novita": return "sparkles"
        default: return "key.fill"
        }
    }
}

let allProviders: [ProviderDef] = [
    ProviderDef(id: "openai", name: "OpenAI", category: .llm),
    ProviderDef(id: "anthropic", name: "Anthropic", category: .llm),
    ProviderDef(id: "deepseek", name: "DeepSeek", category: .llm),
    ProviderDef(id: "google-gemini", name: "Google Gemini", category: .llm),
    ProviderDef(id: "meta-llama", name: "Meta Llama", category: .llm),
    ProviderDef(id: "mistral", name: "Mistral", category: .llm),
    ProviderDef(id: "groq", name: "Groq", category: .llm),
    ProviderDef(id: "cohere", name: "Cohere", category: .llm),
    ProviderDef(id: "perplexity", name: "Perplexity", category: .llm),
    ProviderDef(id: "xai-grok", name: "xAI Grok", category: .llm),
    ProviderDef(id: "openrouter", name: "OpenRouter", category: .llm),
    ProviderDef(id: "together", name: "Together AI", category: .llm),
    ProviderDef(id: "qwen", name: "Qwen", category: .llm),
    ProviderDef(id: "minimax", name: "MiniMax", category: .llm),
    ProviderDef(id: "kimi", name: "Kimi", category: .llm),
    ProviderDef(id: "mimo", name: "Mimo", category: .llm),
    ProviderDef(id: "elevenlabs", name: "ElevenLabs", category: .image),
    ProviderDef(id: "stability", name: "Stability AI", category: .image),
    ProviderDef(id: "replicate", name: "Replicate", category: .image),
    ProviderDef(id: "runway", name: "Runway", category: .image),
    ProviderDef(id: "fal", name: "Fal", category: .image),
    ProviderDef(id: "fireworks", name: "Fireworks AI", category: .image),
    ProviderDef(id: "suno", name: "Suno Music", category: .image),
    ProviderDef(id: "udio", name: "Udio Music", category: .image),
    ProviderDef(id: "huggingface", name: "Hugging Face", category: .cloud),
    ProviderDef(id: "azure-openai", name: "Azure OpenAI", category: .cloud),
    ProviderDef(id: "aws-bedrock", name: "AWS Bedrock", category: .cloud),
    ProviderDef(id: "cloudflare", name: "Cloudflare AI", category: .cloud),
    ProviderDef(id: "deepinfra", name: "DeepInfra", category: .cloud),
    ProviderDef(id: "nebius", name: "Nebius AI", category: .cloud),
    ProviderDef(id: "coze", name: "Coze", category: .other),
    ProviderDef(id: "dify", name: "Dify", category: .other),
    ProviderDef(id: "hyperbolic", name: "Hyperbolic", category: .other),
    ProviderDef(id: "novita", name: "Novita AI", category: .other),
]

func providerGroups() -> [ProviderGroup] {
    ProviderCategory.allCases.filter { $0 != .all }.map { category in
        ProviderGroup(
            id: category,
            providers: allProviders.filter { $0.category == category }
        )
    }
}

func providerDef(for id: String) -> ProviderDef? {
    allProviders.first { $0.id == id }
}
