import SwiftUI
import CoreData

@main
struct zadanie6App: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        loadCategoriesFromAPI()
        loadProductsFromAPI()
        loadOrdersFromAPI()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

let API = "http://127.0.0.1:5000"

extension zadanie6App {
    func loadCategoriesFromAPI() {
        let context = persistenceController.container.viewContext
        let serverURL = API + "/categories"
        
        let url = URL(string: serverURL)
        let request = URLRequest(url: url!)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let categoryEntity = NSEntityDescription.entity(forEntityName: "Category", in: context)
        let dispatchGroup = DispatchGroup()
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard error == nil else {
                return
            }
            guard data != nil else {
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                if let object = json as? [String:Any] {
                    print(object)
                } else if let object = json as? [Any] {
                    for item in object as! [Dictionary<String, AnyObject>] {
                        let id = item["id"] as! Int64
                        let name = item["name"] as! String
                        let info = item["info"] as! String
                        
                        if !checkIfExists(model: "Category", field: "id", fieldValue: id) {
                            let category = NSManagedObject(entity: categoryEntity!, insertInto: context)
                            category.setValue(id, forKey: "id")
                            category.setValue(name, forKey: "name")
                            category.setValue(info, forKey: "info")
                            print("Added category: name: \(name), id:\(id)")
                        } else {
                            print("Category: name: \(name), id: \(id) is in DB")
                        }
                    }
                    try context.save()
                    dispatchGroup.leave()
                } else {
                    print("Invalid JSON")
                }
            } catch {
                dispatchGroup.leave()
                return
            }
        })
        dispatchGroup.enter()
        task.resume()
        dispatchGroup.wait()
    }
    
    func loadProductsFromAPI() {
        let context = persistenceController.container.viewContext
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            let categories = try context.fetch(fetchRequest) as? [NSManagedObject]
            
            for category in categories! {
                let category_id:Int64 = category.value(forKey: "id") as! Int64
                let serverURL = API + "/category/\(category_id)/products"
                let url = URL(string: serverURL)
                let request = URLRequest(url: url!)
                
                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config)
                
                let productEntity = NSEntityDescription.entity(forEntityName: "Product", in: context)
                let dispatchGroup = DispatchGroup()
                
                let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                    guard error == nil else {
                        return
                    }
                    guard data != nil else {
                        return
                    }
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: [])
                        if let object = json as? [String:Any] {
                            print(object)
                        } else if let object = json as? [Any] {
                            for item in object as! [Dictionary<String, AnyObject>] {
                                let id = item["id"] as! Int64
                                let name = item["name"] as! String
                                let price = item["price"] as! Double
                                
                                if !checkIfExists(model: "Product", field: "id", fieldValue: id) {
                                    let product = NSManagedObject(entity: productEntity!, insertInto: context)
                                    product.setValue(id, forKey: "id")
                                    product.setValue(name, forKey: "name")
                                    product.setValue(price, forKey: "price")
                                    product.setValue(category_id, forKey: "category_id")
                                    product.setValue(category, forKey: "category")
                                    print("Added product: name: \(name), id:\(id)")
                                } else {
                                    print("Product: name: \(name), id: \(id) is in DB")
                                }
                            }
                            try context.save()
                            dispatchGroup.leave()
                        } else {
                            print("Invalid JSON")
                        }
                    } catch {
                        dispatchGroup.leave()
                        return
                    }
                })
                dispatchGroup.enter()
                task.resume()
                dispatchGroup.wait()
            }
            
        } catch {
            print("Error")
        }
    }
    
    func loadOrdersFromAPI() {
        let context = persistenceController.container.viewContext
        let serverURL = API + "/orders"
        
        let url = URL(string: serverURL)
        let request = URLRequest(url: url!)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let orderEntity = NSEntityDescription.entity(forEntityName: "Order", in: context)
        let dispatchGroup = DispatchGroup()
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard error == nil else {
                return
            }
            guard data != nil else {
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                if let object = json as? [String:Any] {
                    print(object)
                } else if let object = json as? [Any] {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    for item in object as! [Dictionary<String, AnyObject>] {
                        let id = item["id"] as! Int64
                        let total_value = item["total_value"] as! Double
                        let order_status = item["order_status"] as! String
                        let products = item["products"] as! [Int64]
                        
                        let uniqueProductsSet: Set<Int64> = Set(products)
                        let uniqueProductsArray: [Int64] = Array(uniqueProductsSet)
                        
                        if let dateString = item["order_date"] as? String,
                           let order_date = dateFormatter.date(from: dateString) {
                            
                            if !checkIfExists(model: "Order", field: "id", fieldValue: id) {
                                let order = NSManagedObject(entity: orderEntity!, insertInto: context)
                                order.setValue(id, forKey: "id")
                                order.setValue(total_value, forKey: "total_value")
                                order.setValue(order_status, forKey: "order_status")
                                order.setValue(order_date, forKey: "order_date")
                                order.setValue(products, forKey: "ordered_items")
                                
                                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
                                fetchRequest.predicate = NSPredicate(format: "id IN %@", uniqueProductsArray)
                                do {
                                    let products_data = try context.fetch(fetchRequest) as! [NSManagedObject]
                                    for product in products_data {
                                        order.mutableSetValue(forKey: "products").add(product)
                                    }
                                    print("Added order: id:\(id)")
                                } catch {
                                    print("Error fetching products")
                                }
                            } else {
                                print("Order: id: \(id) is in DB")
                            }
                        }
                    }
                    try context.save()
                    dispatchGroup.leave()
                } else {
                    print("Invalid JSON")
                }
            } catch {
                dispatchGroup.leave()
                return
            }
        })
        dispatchGroup.enter()
        task.resume()
        dispatchGroup.wait()
    }
    
    func checkIfExists(model: String, field: String, fieldValue: CVarArg) -> Bool {
        let context = persistenceController.container.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: model)
        fetchRequest.predicate = NSPredicate(format: "\(field) = %d", fieldValue)
        
        do {
            let fetchResults = try context.fetch(fetchRequest) as? [NSManagedObject]
            if fetchResults!.count > 0 {
                return true
            }
            return false
        } catch {
            print("Error")
        }
        return false
    }
    
    func clearDB() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Order.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistenceController.container.viewContext.execute(deleteRequest)
        } catch {
            print(error.localizedDescription)
        }
        
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Product.fetchRequest()
        let deleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        
        do {
            try persistenceController.container.viewContext.execute(deleteRequest1)
        } catch {
            print(error.localizedDescription)
        }
        
        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
        let deleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        
        do {
            try persistenceController.container.viewContext.execute(deleteRequest2)
        } catch {
            print(error.localizedDescription)
        }
    }
}
