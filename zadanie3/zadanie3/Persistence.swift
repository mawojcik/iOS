import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
            let result = PersistenceController(inMemory: true)
            
            return result
        }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "zadanie3")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        loadFixtures()
    }

    func loadFixtures() {
        let viewContext = container.viewContext
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            let count = try viewContext.count(for: fetchRequest)
            if count > 0 { return }
            
            let electronics = Category(context: viewContext)
            electronics.id = UUID()
            electronics.name = "Elektronika"
            
            let books = Category(context: viewContext)
            books.id = UUID()
            books.name = "Książki"
            
            let macbook = Product(context: viewContext)
            macbook.id = UUID()
            macbook.name = "MacBook Pro"
            macbook.desc = "Najpotężniejszy laptop Apple z procesorem M3."
            macbook.price = 9999.00
            macbook.category = electronics
            
            let cleanCode = Product(context: viewContext)
            cleanCode.id = UUID()
            cleanCode.name = "Czysty Kod"
            cleanCode.desc = "Podręcznik dobrego programowania."
            cleanCode.price = 89.00
            cleanCode.category = books
            
            try viewContext.save()
            print("Fixtures załadowane pomyślnie!")
            
        } catch {
            let nsError = error as NSError
            print("Błąd podczas ładowania fixtures: \(nsError)")
        }
    }
}
