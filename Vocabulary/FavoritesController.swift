//
//  FavoritesController.swift
//  Vocabulary
//
//  Created by Alex on 02.07.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import SwipeCellKit

class FavoritesController: SpecialListController {
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let word = words[indexPath.row]
        
        let editAction = SwipeAction(style: .`default`, title: "Edit".localized()) { action, indexPath in
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.word = word
            appDelegate.editWord()
        }
        editAction.backgroundColor = lightGreenColor
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete".localized()) { action, indexPath in
            RealmHelper.sharedInstance.realm.beginWrite()
            RealmHelper.sharedInstance.realm.delete(self.words[indexPath.row])
            try! RealmHelper.sharedInstance.realm.commitWrite(withoutNotifying: [self.wordsToken])
            if tableView.numberOfRows(inSection: 0) > 1 {
                tableView.deleteRows(at: [indexPath], with: .left)
            } else {
                tableView.reloadData()
                self.setEditButton()
            }
        }
        deleteAction.backgroundColor = pinkColor
        
        
        
        let favoriteTitle = word.isFavorite ? "Unfave".localized() : "Fave".localized()
        
        let favoriteAction = SwipeAction(style: .`default`, title: favoriteTitle) { action, indexPath in
            try! RealmHelper.sharedInstance.realm.write {
                if word.isFavorite {
                    self.words.remove(objectAtIndex: indexPath.row)
                    word.isFavorite = false
                } else {
                    self.words.append(word)
                }
            }
        }
        
        favoriteAction.backgroundColor = yellowColor
        
        
        let shareAction = SwipeAction(style: .`default`, title: "Share".localized()) { action, indexPath in
            let objectsToShare = [word.name + " " + word.translation] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
        shareAction.backgroundColor = lightBlueColor
        
        return [deleteAction, editAction, favoriteAction, shareAction]
    }
}
