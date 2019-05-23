//
//  ViewController.swift
//  D00
//
//  Created by Artem KUPRIIANETS on 1/15/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
    @IBOutlet weak var outputLabel: UILabel!
    
    let expr: Expression = Expression()
    var nextOperator: String = ""

    @IBAction func clearButton(sender: UIButton) {
        
        expr.nilProperties()
		outputLabel.text = "0"
	}
	
	@IBAction func getResButton(sender: UIButton) {
        
		var fl: Bool?
		if expr.canCalculate() {
			var res = expr.calcul()
            if let nres = Double(res) {
                if nres <= Double(INT64_MAX) && Double(Int64(nres)) == nres {
                    res = String(Int64(Double(res)!))
					expr.isDouble = false
					fl = true
                }
            } else {
				outputLabel.text = res
				expr.nilProperties()
				return
			}
			if fl == nil || (fl != nil && !fl!) {
				expr.isDouble = true
			}
			outputLabel.text = res
            expr.updateProperties(res: res)
        }
    }
    
    
    @IBAction func makeDouble(_ sender: UIButton) {
        
        if (sender.titleLabel?.text) != nil {
            outputLabel.text = expr.appendDot()
        }
    }
    
	@IBAction func negButton(sender: UIButton) {
        
        if (sender.titleLabel?.text) != nil {
            if outputLabel.text == "Can't divide by 0" {
                outputLabel.text = "0"
            }
			outputLabel.text = expr.changeSign()
		}
	}
    
    @IBAction func numberButton(_ sender: UIButton) {
        
        if let num = sender.titleLabel?.text {
            outputLabel.text = expr.saveNumber(num: num) ?? outputLabel.text
        }
    }
	
	
    @IBAction func percentButton(_ sender: UIButton) {
        
        if let str = sender.titleLabel?.text {
            if outputLabel.text == "Can't divide by 0" {
                outputLabel.text = "0"
            }
            nextOperator = str
            if nextOperator == "%" {
              outputLabel.text = expr.calcPercent() ?? outputLabel.text
            }
        }
    }
    
	@IBAction func operatorButton(sender: UIButton) {
        
		if let str = sender.titleLabel?.text {
            if outputLabel.text == "Can't divide by 0" {
                outputLabel.text = "0"
            }
			nextOperator = str
			if expr.string1 != nil {
				if expr.string2 != nil {
					var res = expr.calcul()
					if let nres = Double(res) {
						if res.count < 23 && nres <= Double(INT64_MAX) && Double(Int64(nres)) == nres {
							res = String(Int64(Double(res)!))
						}
					} else {
						outputLabel.text = res
						expr.nilProperties()
						return
					}
					outputLabel.text = res
					expr.string1 = String(res)
					expr.string2 = nil
				}
				expr.oper = nextOperator
				expr.isDouble = false
			}
		}
	}
	
	
    override func viewDidLoad() {
		super.viewDidLoad()
        outputLabel.adjustsFontSizeToFitWidth = true
        outputLabel.allowsDefaultTighteningForTruncation = true
        outputLabel.minimumScaleFactor = 0.4
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
}


