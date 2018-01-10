//
//  FindSynonymsModel.swift
//  Synonymes
//
//  Created by  Shadow on 05.01.18.
//  Copyright © 2018  Shadow. All rights reserved.
//

import UIKit
import CoreData
import CSV



class SynonymsModel {
    
    var senderVC = UIViewController()
    
    var popularTagsList = [(idx: Int, name: String)]()
    
    /// Свойства выбранного популярного тага
    ///
    /// idx: индекс - изначально берётся из CSV
    ///
    /// name: имя
    struct SelectedPopularTagProps {
        var id: Int = 0
        var name: String = ""
    }
    
    var selectedPopularTagProps = SelectedPopularTagProps()
   
    /// Struct for recieved synonyms
    private struct RecievedSynonyms {
        var parentTagId: Int = 0
        var synonymId: [Int] = []
        var synonymsArray: [String] = []
    }
    
    private var synonymsList = RecievedSynonyms()
    
    private struct JSONStruct: Decodable {
        var word: String?
        var score: Int?
        var tags: [String]?
    }
    
//    /// Массив всех полученных синонимов
//    private var arrOfResponse: [String] = []
    
    //MARK: -
    /// Clear old text
    private func clearTheText (_ view: UIViewController){
        if let view = view as? MainController {
            view.textViewSynonyms.text = ""
            view.textViewSynonyms.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            print("clear the old text")
        }
    }
    
    
    /// Заполнить поле синонимами
    /// word передается только для отображения на вью
    /// - Parameters:
    ///   - view: Вьюха - MainController
    ///   - word: Текущее слово
    private func fillTheSynonyms (_ view: UIViewController, word: String){
        if let view = view as? MainController {
            view.total.text = "total = " + String (synonymsList.synonymsArray.count)
            view.lblCurrentWord.text = "current word = " + word
            
            if synonymsList.synonymsArray.count > 0 {
                
                for idx in 0...synonymsList.synonymsArray.count - 1 {
                    view.textViewSynonyms.text! += synonymsList.synonymsArray[idx]  + ", "//arrOfResponse[idx] + ", "
                }
             print ("synonymsList.synonymsArray.count = \(synonymsList.synonymsArray.count)")
             addToBase ()
            } else { print ("synonymsList.synonymsArray.count = \(synonymsList.synonymsArray.count)")}
        }
    }
    
    
    ///Clear the array with contains old words
    ///
    /// очистить массив синонимов перед следующим вызовом
    private func clearTheSynonymsList (){
        self.synonymsList.synonymsArray.removeAll()
        self.synonymsList.synonymId.removeAll()
        self.synonymsList.parentTagId = -1
    }
    
    /// spinner startAnimating()
    private func spinnerStart (_ view: UIViewController){
        if let view = view as? MainController {
            view.spinner.startAnimating()
        }
    }
    
    /// spinner stopAnimating()
    private func spinnerStop (_ view: UIViewController){
        if let view = view as? MainController {
            view.spinner.stopAnimating()
        }
    }
    
    
    
    /// Clear the input text and resign first responder
    func clearTheTextAndResignFirstResponder (_ view: UIViewController){
        if let view = view as? MainController {
            view.textForSend.text = ""
            view.textForSend.resignFirstResponder()
        }
    }
    
    
    /// Add popular tags and its synonyms to base
    private func addToBase (){
        
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        print (container.name)
        
        let context: NSManagedObjectContext = container.viewContext
        

        
        for idx in 0...synonymsList.synonymsArray.count - 1 {
            
            let currentPopularTag = PopularTags(context: context )
            currentPopularTag.idPopular = Int32 ( selectedPopularTagProps.id )
            currentPopularTag.popularName = selectedPopularTagProps.name

            
            let synonymTags = SynonymTags(context: currentPopularTag.managedObjectContext! )
            synonymTags.synonymName = synonymsList.synonymsArray[idx]
            synonymTags.idSynonym   = Int32 ( synonymsList.synonymId[idx])
            synonymTags.idOfPopular = Int32 ( selectedPopularTagProps.id )


            currentPopularTag.addToSynonyms(synonymTags)

        }

        do {
            try context.save()
        } catch {
            let error = error as NSError
            print ("Unresolved error \(error), \(error.userInfo)")
        }

        
        
//        if let joesTweets = popularTag.synonymsRel as? Set<SynonymTags>{   // joe.tweets - это NSSet, используем as?
//            if joesTweets.contains(synonym) { print ("yes!") }  // yes!
//        }


        


        
    }
    
    
    /// Load Popular tags from CSV
    func readFileOfPopularTags (_ view: UIViewController, completion: (_ complete: Bool)->() ){
        
        popularTagsList.removeAll()
        
        let path = Bundle.main.path(forResource: "allPopularTags", ofType: "csv")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path!) {
            
            if let stream = InputStream(fileAtPath: String(describing: path!)){
                print ("fileAtPath = \(path!)")
                let csv = try! CSVReader(stream: stream, hasHeaderRow: true)
                
               // let headerRow = csv.headerRow!

                while let _ = csv.next() {      // while let row = csv...
                    let idx : Int = Int (csv["idx"]!)!
                    let name = csv["popularTags"]!
                    popularTagsList.append((idx: idx, name: name))
                }
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    
    
    /// В центр сообщений добавить событие на окончание запроса на сервер
    func addEvent(){
        NotificationCenter.default.addObserver(self ,
                                               selector: #selector(responseTaken),
                                               name: NSNotification.Name("finished"),
                                               object: nil)
    }
    
    
    @objc func responseTaken (){
        if let view = senderVC as? MainController {
            
            DispatchQueue.main.async { self.fillTheSynonyms (view, word: word) }
            DispatchQueue.main.async { self.spinnerStop(view) }

        }
        
    }
    
    
    
    
    
    /// Запомнить выбранный популярный тэг и его индекс
    func setSelectedPopularTagsProps (_ idx : Int){
        selectedPopularTagProps.id   = popularTagsList[idx].idx
        selectedPopularTagProps.name = popularTagsList[idx].name
    }
    
    
    /// Send request with key-word to the server
    ///
    /// 1. Очистить текстовое поле
    ///
    /// 2. старт анимации
    ///
    /// 3. Отправить запрос
    ///
    /// 4. При получении разнести синонимы в структуру synonymsList
    ///
    /// selectedPopularTagIdx - индекс текущего популярного тэга    - изменяется при смене фокуса ячейки в таблице
    ///
    /// selectedPopularTagName - имя текущего популярного тэга      - изменяется при смене фокуса ячейки в таблице
    /// - Parameters:
    ///   - view: Вьюха - MainController
    ///   - word: Текущее слово
    
    func sendRequest (_ view: UIViewController, word: String){
        
        var getURL: String = ""
        getURL = "https://api.datamuse.com/words?ml=" + word + "&max=150"
        
        guard let url = URL (string: getURL ) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("ERROR!! : \(String(describing: error?.localizedDescription)) ")
            } else {
                
                self.clearTheSynonymsList ()
                
                guard let data = data else { return }
                do {
                    
                    let json = try JSONDecoder().decode([JSONStruct].self, from: data)
                    self.synonymsList.parentTagId = self.selectedPopularTagProps.id
                    
                    for item in json {
                        self.synonymsList.synonymId.append(self.synonymsList.synonymsArray.count)
                        self.synonymsList.synonymsArray.append(item.word!)
                    }
                    
                    
                } catch let errorNo {
                    print ("Error JSON decoding. err = ", errorNo)
                }
            }
            }.resume()
    }
    
    
    
    
    /// Get popular tag from cell AND call "Send request"
    func getSelectedPopularTag (at index: Int, view: UIViewController){
        
        selectedPopularTagProps.name = popularTagsList[index].name
        selectedPopularTagProps.id   = popularTagsList[index].idx
        
        if let view = view as? MainController {
            
            /// if selected word not nil - call send request
            let word = selectedPopularTagProps.name
            
                view.textForSend.text = word
                clearTheTextAndResignFirstResponder(view)
            
                clearTheText (view)
                spinnerStart(view)

                sendRequest(view, word: word.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
    
    /// Сохранить данные в файл CSV
    /// Формат:
    /// id_popular ; popular_tag ; syn_1, syn_2, .... syn_last
    
    /// Save base to csv
    func saveToFile(){
        let file = "file.txt" //this is the file. we will write to and read from it
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
           let fileURL = dir.appendingPathComponent(file)
            
            let stream = OutputStream(toFileAtPath: fileURL.path, append: false)!
            let csv = try! CSVWriter(stream: stream, delimiter: ";")
            
            try! csv.write(row: ["id", "popular_tag","synonyms"])
            
            var allSynonyms: String = ""
            
            for idxOfPopular in 0...popularTagsList.count - 1 {
                for idx in 0...synonymsList.synonymsArray.count - 1 {
                    allSynonyms += ", " + synonymsList.synonymsArray [idx]
                }
                
                //sendRequest(view, word: word.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
            try! csv.write(row: ["-1", "na", allSynonyms])
            csv.stream.close()

        }
    }
    
    
    
}
