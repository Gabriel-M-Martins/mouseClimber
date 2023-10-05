//
//  MainMenu.swift
//  mouseClimber
//
//  Created by Fabrício Masiero on 27/09/23.
//

import Foundation
import SpriteKit

class MenuScene: SKScene {
	override func didMove(to view: SKView) {
		// Adicione botões para as opções
		let leaderboardButton = SKLabelNode(text: "Leaderboard")
		leaderboardButton.name = "leaderboardButton"
		leaderboardButton.position = CGPoint(x: view.frame.minX, y: view.frame.maxY / 2 )
		addChild(leaderboardButton)
		
		let startButton = SKLabelNode(text: "Iniciar Jogo")
		startButton.name = "startButton"
		startButton.position = CGPoint(x: view.frame.minX, y: leaderboardButton.position.y + view.frame.maxY / 10)
		addChild(startButton)
		
		let settingsButton = SKLabelNode(text: "Configurações")
		settingsButton.name = "settingsButton"
		settingsButton.position = CGPoint(x: view.frame.minX, y: leaderboardButton.position.y - view.frame.maxY / 10)
		addChild(settingsButton)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let location = touch.location(in: self)
			let touchedNode = atPoint(location)
			
			if touchedNode.name == "startButton" {
				// Transição para a cena de jogo
				let gameScene = GameScene(size: size)
				gameScene.scaleMode = scaleMode
				view?.presentScene(gameScene)
			} else if touchedNode.name == "leaderboardButton" {
				// Transição para a cena de leaderboard
				// Implemente esta parte
			} else if touchedNode.name == "settingsButton" {
				// Transição para a cena de configurações
				// Implemente esta parte
			}
		}
	}
}
