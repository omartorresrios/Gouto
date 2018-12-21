//
//  TermsOfServiceController.swift
//  Humans
//
//  Created by Omar Torres on 9/07/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit

class TermsOfServiceController: UIViewController {
    
    let backView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "back_button")!.withRenderingMode(.alwaysTemplate))
        image.tintColor = UIColor.mainBlue()
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    let messageTextView: UITextView = {
        let tv = UITextView()
        tv.text = "Acuerdo de licencia del usuario final de la aplicación\n\nEste Acuerdo de Licencia de Usuario Final ('Acuerdo') es entre usted y Humans y rige el uso de esta aplicación disponible a través del Apple App Store. Al instalar la aplicación Humans, acepta quedar obligado por este Acuerdo y entiende que no hay tolerancia para el contenido objetable. Si no está de acuerdo con los términos y condiciones de este Acuerdo, no tiene derecho a utilizar la aplicación Humans.\n\nPara garantizar que Humans proporcione la mejor experiencia posible para todos, aplicamos fuertemente una política de no tolerancia para contenido objetable. Si ve contenido inapropiado, utilice la función 'Informar como ofensivo' en cada publicación.\n\n1. Partes\n\nEste Acuerdo se establece entre usted y Humans y no Apple, Inc. ('Apple'). No obstante lo anterior, usted reconoce que Apple y sus subsidiarias son terceros beneficiarios de este Acuerdo y Apple tiene el derecho de hacer cumplir este Acuerdo contra usted. Humans, no Apple, es el único responsable de la aplicación Humans y su contenido.\n\n2. Privacidad\n\nHumans puede recopilar y utilizar información sobre el uso de la aplicación Humans, incluyendo ciertos tipos de información de y sobre su dispositivo. Humans puede utilizar esta información, siempre y cuando esté en un formulario que no lo identifique personalmente, para medir el uso y el rendimiento de la aplicación Humans.\n\n3. Licencia limitada\n\nHumans le otorga una licencia limitada, no exclusiva, no transferible y revocable para usar la aplicación Humans para sus fines personales y no comerciales. Sólo puedes usar la aplicación App App en dispositivos Apple que poseas o controlas y según lo permitan los Términos de servicio de la App Store.\n\n4. Restricciones de edad\n\nAl utilizar la aplicación Humans, usted declara y garantiza que tiene 17 años de edad o más y acepta estar obligado por este Acuerdo; (B) si usted es menor de 17 años de edad, ha obtenido el consentimiento verificable de un padre o tutor legal; Y (c) el uso de la aplicación Humans no viola ninguna ley o regulación aplicable. Su acceso a la aplicación Humans puede ser terminado sin previo aviso si Humans cree, a su sola discreción, que tiene menos de 17 años y no ha obtenido el consentimiento verificable de un padre o tutor legal. Si usted es padre o tutor legal y usted da su consentimiento para que su hijo use la aplicación Humans, usted acepta estar obligado por este Acuerdo con respecto al uso de la aplicación Humans por su hijo.\n\n5. Política de contenido objetable\n\nEl contenido no se puede enviar a Humans, que moderará todo el contenido y, en última instancia, decidirá si publicará o no una presentación en la medida en que dicho contenido incluya, esté en conjunción con, o junto con, Contenido objetable. El contenido objetable incluye, pero no se limita a: (i) materiales sexualmente explícitos; (Ii) contenido obsceno, difamatorio, difamatorio, calumnioso, violento y / o ilegal o profanidad; (Iii) contenido que infrinja los derechos de cualquier tercero, incluyendo derechos de autor, marca comercial, privacidad, publicidad u otro derecho personal o de propiedad, o que sea engañoso o fraudulento; (Iv) contenido que promueva el uso o venta de sustancias ilegales o reguladas, productos de tabaco, municiones y / o armas de fuego; Y (v) juegos de azar, incluyendo sin limitación, cualquier casino en línea, libros de deportes, bingo o póquer.\n\n6. Garantía\n\nHumans renuncia a todas las garantías sobre la aplicación Humans en la medida máxima permitida por la ley. En la medida en que exista una garantía bajo la ley que no pueda ser rechazada, Humans no Apple, será el único responsable de dicha garantía.\n\n7. Mantenimiento y Soporte\n\nHumans proporciona un mínimo de mantenimiento o soporte para ello, pero no en la medida en que la ley aplicable requiera cualquier mantenimiento o soporte, Humans, no Apple, estará obligado a proporcionar dicho mantenimiento o soporte.\n\n8. Reclamaciones de productos\n\nHumans no Apple, es responsable de responder a cualquier reclamación relacionada con la aplicación Humans o uso de la misma, incluyendo pero no limitado a: (i) cualquier reclamación por responsabilidad del producto; (Ii) cualquier reclamación de que la App Humans no cumple con cualquier requisito legal o regulatorio aplicable; Y (iii) cualquier reclamación derivada de la protección del consumidor o legislación similar. Nada en este Acuerdo se considerará una admisión de que usted puede tener tales reclamaciones.\n\n9. Reclamaciones de propiedad intelectual de terceros\n\nHumans no estará obligado a indemnizarlo o defenderlo con respecto a cualquier reclamación de terceros que surja o se relacione con la aplicación Humans. En la medida en que Humans esté obligado a proporcionar indemnización por la ley aplicable, Humans, no Apple, será el único responsable de la investigación, defensa, liquidación y descargo de cualquier reclamo de que la aplicación Infringe cualquier derecho de propiedad intelectual de terceros.\n\nInformación de contacto:\n\nSi tienes alguna sugerencia sobre estos Términos de Servicio o alguna queja, por favor contáctanos a addhumans1@gmail.com"
        tv.font = UIFont(name: "SFUIDisplay-Regular", size: 14)
        tv.textColor = .black
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(backView)
        
        backView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 18, height: 18)
        
        let backViewTap = UITapGestureRecognizer(target: self, action: #selector(goBackView))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(backViewTap)
        
        view.addSubview(messageTextView)
        messageTextView.anchor(top: backView.bottomAnchor, left: backView.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 8, width: 0, height: 0)
        
    }
    
    @objc func goBackView() {
        _ = navigationController?.popViewController(animated: true)
    }
}
