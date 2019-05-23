//
//  Expression.swift
//  D00
//
//  Created by Artem KUPRIIANETS on 22/02/2019.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import Foundation

class Expression {
	
	var string1: String?
	var oper: String?
	var string2: String?
	var lastSum: String?
	var isDouble: Bool
	
	init() {
		isDouble = false
	}
	
	func nilProperties() {
		string1 = nil
		oper    = nil
		string2 = nil
		lastSum = nil
		isDouble = false
	}
	
	private func changeNumSign(str: String) -> String {
		var nb = Double(str)!
		if nb != 0 {
			let res: String
			nb = nb * -1
			if nb > Double(Int64.min) && nb <= Double(INT64_MAX) && Double(Int64(nb)) == nb {
				res = String(Int64(nb))
			} else {
				res = String(nb)
			}
			return res
		}
		return "0"
	}
	
	func calcPercent() -> String? {
		var fl: Bool?
		if let str = string1 {
			let nb1 : Double = overflow(OptString: str)
			var res = String(nb1 * Double(0.01))
			if let nres = Double(res) {
				if res.count < 23 && nres <= Double(INT64_MAX) && Double(Int64(nres)) == nres {
					res = String(Int64(Double(res)!))
					isDouble = false
					fl = true
				}
			}
			if fl == nil || (fl != nil && !fl!) {
				isDouble = true
			}
			updateProperties(res: res)
			return lastSum ?? ""
		}
		return nil
	}
	
	func changeSign() -> String {
		if string2 == nil {
			if let str1 = string1 {
				string1 = changeNumSign(str: str1)
				return string1!
			}
		} else {
			if let str2 = string2 {
				string2 = changeNumSign(str: str2)
				return string2!
			}
		}
		return ""
	}
	
	func helpAppendDot(str: String) -> String? {
		var res: String?
		if str.count < 21 {
			if !isDouble {
				res = str + "."
			}
			isDouble = true
		}
		return res
	}
	
	func appendDot() -> String {
		if  oper != nil {
			if let str2 = string2 {
				if let res = helpAppendDot(str: str2) {
					string2 = res
				}
			}
			return string2 ?? (string1 ?? "0")
		} else {
			if let str1 = string1 {
				if let ln = lastSum {
					if !isDouble {
						string1 = ln + "."
					}
					isDouble = true
					lastSum = nil
				}
				if let res = helpAppendDot(str: str1) {
					string1 = res
				}
			}
			return string1 ?? "?"
		}
	}
	
	func saveNumber(num: String) -> String? {
		if  oper != nil {
			if let str2 = string2 {
				if str2.count < 22 {
					string2 = str2 + num
				}
			} else {
				string2 = num
			}
			return string2
		}
		else {
			if let str1 = string1 {
				if lastSum != nil {
					lastSum = nil
					string1 = num
				} else if str1.count < 22 {
					string1 = str1 + num
				}
			} else {
				string1 = num
			}
			return string1
		}
	}
	
	func updateProperties(res: String) {
		lastSum = String(res)
		string1 = lastSum
		oper = nil
		string2 = nil
	}
	
	func canCalculate() -> Bool {
		return string1 != nil && string2 != nil && oper != nil
	}
	
	private func overflow(OptString string:String?) -> Double
	{
		var nb : Double
		if let res = string {
			nb = Double(res)!
			return (nb)
		}
		return (-42)
	}
	
	func calcul() -> String
	{
		if let nbr1 = string1, let nbr2 = string2, let op = oper {
			let nb1 : Double = overflow(OptString: nbr1)
			let nb2 : Double = overflow(OptString: nbr2)
			var sum : Double = 0
				switch op {
				case "+", "–":
					if nb1 <= Double(INT64_MAX) && nb2 <= Double(INT64_MAX)
						&& (Double(Int64(nb1)) != nb1 || Double(Int64(nb2)) != nb2) {
						sum = op == "+" ? nb1 + nb2 : nb1 - nb2
					} else if (nb1 <= Double(INT64_MAX) && nb2 <= Double(INT64_MAX)) {
						sum = op == "+" ? Double(Int64(nb1) + Int64(nb2)) : Double(Int64(nb1) - Int64(nb2))
					} else {
						sum = op == "+" ? nb1 + nb2 : nb1 - nb2
					}
				case "x":
					sum = nb1 * nb2
				case "÷":
					if nb2 != 0 {
						sum = nb1 / nb2
					} else {
						nilProperties()
						return ("Can't divide by 0")
					}
				default :
					sum = 0
				}
				return (String(sum))
		}
		nilProperties()
		return ("Error")
	}
}
