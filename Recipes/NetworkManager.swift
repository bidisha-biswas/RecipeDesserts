import Foundation

class NetworkManager {
    static let shared = NetworkManager()

    init() { }

    func fetchMealDetails() async throws -> Meal {
        let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=53049")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, _) = try await URLSession.shared.data(for: request)
        let mealResponse = try JSONDecoder().decode(MealResponse.self, from: data)
        return mealResponse.meals[0]
    }
}
