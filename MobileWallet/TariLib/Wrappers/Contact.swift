//  Contact.swift

/*
	Package MobileWallet
	Created by Jason van den Berg on 2019/11/16
	Using Swift 5.0
	Running on macOS 10.15

	Copyright 2019 The Tari Project

	Redistribution and use in source and binary forms, with or
	without modification, are permitted provided that the
	following conditions are met:

	1. Redistributions of source code must retain the above copyright notice,
	this list of conditions and the following disclaimer.

	2. Redistributions in binary form must reproduce the above
	copyright notice, this list of conditions and the following disclaimer in the
	documentation and/or other materials provided with the distribution.

	3. Neither the name of the copyright holder nor the names of
	its contributors may be used to endorse or promote products
	derived from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
	CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
	OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
	NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
	HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
	OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation

enum ContactError: Error {
    case generic(_ errorCode: Int32)
}

class Contact {
    private var ptr: OpaquePointer

    var pointer: OpaquePointer {
        return ptr
    }

    var alias: (String, Error?) {
        var errorCode: Int32 = -1
        let aliasPointer = contact_get_alias(ptr, UnsafeMutablePointer<Int32>(&errorCode))
        guard errorCode == 0 else {
            return ("", ContactError.generic(errorCode))
        }

        return (String(validatingUTF8: aliasPointer!)!, nil)
    }

    var publicKey: (PublicKey?, Error?) {
        var errorCode: Int32 = -1
        let result = PublicKey(pointer: contact_get_public_key(ptr, UnsafeMutablePointer<Int32>(&errorCode)))
        guard errorCode == 0 else {
            return (nil, ContactError.generic(errorCode))
        }

        return (result, nil)
    }

    init(contactPointer: OpaquePointer) {
        ptr = contactPointer
    }

    init(alias: String, publicKey: PublicKey) throws {
        let aliasPointer = UnsafeMutablePointer<Int8>(mutating: (alias as NSString).utf8String)
        var errorCode: Int32 = -1
        let result = contact_create(aliasPointer, publicKey.pointer, UnsafeMutablePointer<Int32>(&errorCode))
        guard errorCode == 0 else {
            throw ContactError.generic(errorCode)
        }
        ptr = result!
    }

    deinit {
        contact_destroy(ptr)
    }
}
