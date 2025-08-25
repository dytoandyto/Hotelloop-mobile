class Hotel {
  final String name;
  final String imageUrl;
  final double rating;
  final String price;

  Hotel({
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.price,
  });
}

final List<Hotel> popularHotels = [
  Hotel(
    name: 'Sigma Hotel',
    imageUrl: 'lib/assets/images/hotels/hotel1.png', 
    rating: 4.5,
    price: 'Rp 750.000,-/ night',
  ),
  Hotel(
    name: 'Riverside Boutique',
    imageUrl: 'lib/assets/images/hotels/hotel2.png',
    rating: 4.8,
    price: 'Rp 825.000,-/ night',
  ),
  Hotel(
    name: 'The Grand Plaza',
    imageUrl: 'lib/assets/images/hotels/hotel3.png',
    rating: 4.3,
    price: 'Rp 690.000,-/ night',
  ),
];