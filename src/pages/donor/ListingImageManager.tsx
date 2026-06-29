import { useState, useRef } from 'react';
import { Layout } from '../../components/layout/Layout';
import { Card } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { Upload, X, Image, Camera, Eye } from 'lucide-react';

interface ImageEntry {
  id: number;
  url: string;
  name: string;
  uploadedAt: string;
  listingId: number;
  listingTitle: string;
}

const sampleImages: ImageEntry[] = [
  { id: 1, url: 'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?w=400&h=300&fit=crop', name: 'biryani_01.jpg', uploadedAt: '2026-06-29T15:00:00', listingId: 1, listingTitle: 'Chicken Biryani (30 servings)' },
  { id: 2, url: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=300&fit=crop', name: 'bread_01.jpg', uploadedAt: '2026-06-29T14:00:00', listingId: 2, listingTitle: 'Bread Loaves Bundle' },
  { id: 3, url: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=300&fit=crop', name: 'vegetables_01.jpg', uploadedAt: '2026-06-29T13:00:00', listingId: 3, listingTitle: 'Vegetable Mixed Platter' },
];

export function ListingImageManager() {
  const [images, setImages] = useState<ImageEntry[]>(sampleImages);
  const [preview, setPreview] = useState<ImageEntry | null>(null);
  const [dragging, setDragging] = useState(false);
  const fileRef = useRef<HTMLInputElement>(null);

  const handleFileChange = (files: FileList | null) => {
    if (!files) return;
    Array.from(files).forEach((file, i) => {
      const reader = new FileReader();
      reader.onload = (e) => {
        setImages(prev => [...prev, {
          id: Date.now() + i,
          url: e.target?.result as string,
          name: file.name,
          uploadedAt: new Date().toISOString(),
          listingId: 0,
          listingTitle: 'Unassigned',
        }]);
      };
      reader.readAsDataURL(file);
    });
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setDragging(false);
    handleFileChange(e.dataTransfer.files);
  };

  const handleDelete = (id: number) => setImages(prev => prev.filter(i => i.id !== id));

  return (
    <Layout
      title="Listing Image Manager"
      subtitle="Upload and manage photos for your food listings"
      actions={
        <Button icon={<Upload size={16} />} onClick={() => fileRef.current?.click()}>
          Upload Images
        </Button>
      }
    >
      <input ref={fileRef} type="file" accept="image/*" multiple className="hidden"
        onChange={e => handleFileChange(e.target.files)} />

      {preview && (
        <div className="fixed inset-0 bg-black/70 z-50 flex items-center justify-center p-6" onClick={() => setPreview(null)}>
          <div className="bg-white rounded-2xl overflow-hidden max-w-lg w-full" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between p-4 border-b">
              <p className="font-semibold text-gray-900">{preview.name}</p>
              <button onClick={() => setPreview(null)} className="text-gray-400 hover:text-gray-600"><X size={20} /></button>
            </div>
            <img src={preview.url} alt={preview.name} className="w-full object-cover max-h-96" />
            <div className="p-4 text-sm text-gray-500">
              <p>Listing: <span className="text-gray-900 font-medium">{preview.listingTitle}</span></p>
              <p>Uploaded: {new Date(preview.uploadedAt).toLocaleString()}</p>
            </div>
          </div>
        </div>
      )}

      <div
        onDragOver={e => { e.preventDefault(); setDragging(true); }}
        onDragLeave={() => setDragging(false)}
        onDrop={handleDrop}
        onClick={() => fileRef.current?.click()}
        className={`border-2 border-dashed rounded-2xl p-12 text-center cursor-pointer mb-8 transition-all ${
          dragging ? 'border-green-400 bg-green-50' : 'border-gray-200 bg-gray-50 hover:border-green-300 hover:bg-green-50'
        }`}
      >
        <div className="flex items-center justify-center gap-4 mb-4">
          <Camera size={32} className="text-gray-300" />
          <Upload size={32} className="text-gray-300" />
        </div>
        <p className="font-medium text-gray-700">Drag & drop images here, or click to browse</p>
        <p className="text-sm text-gray-400 mt-1">Supports JPG, PNG, WEBP up to 10MB each</p>
      </div>

      <Card padding={false}>
        <div className="px-5 py-4 border-b border-gray-100 flex items-center gap-2">
          <Image size={18} className="text-gray-500" />
          <h2 className="font-semibold text-gray-900">Uploaded Images ({images.length})</h2>
        </div>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 p-5">
          {images.map(img => (
            <div key={img.id} className="group relative rounded-xl overflow-hidden border border-gray-100 bg-gray-50">
              <img src={img.url} alt={img.name} className="w-full h-36 object-cover" />
              <div className="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2">
                <button onClick={() => setPreview(img)}
                  className="w-9 h-9 bg-white rounded-lg flex items-center justify-center text-gray-700 hover:bg-gray-100">
                  <Eye size={16} />
                </button>
                <button onClick={() => handleDelete(img.id)}
                  className="w-9 h-9 bg-red-500 rounded-lg flex items-center justify-center text-white hover:bg-red-600">
                  <X size={16} />
                </button>
              </div>
              <div className="p-2.5">
                <p className="text-xs font-medium text-gray-800 truncate">{img.name}</p>
                <p className="text-xs text-gray-400 mt-0.5 truncate">{img.listingTitle}</p>
              </div>
            </div>
          ))}
          <button
            onClick={() => fileRef.current?.click()}
            className="h-36 rounded-xl border-2 border-dashed border-gray-200 hover:border-green-400 hover:bg-green-50 flex items-center justify-center text-gray-400 hover:text-green-500 transition-colors"
          >
            <div className="text-center">
              <Upload size={24} className="mx-auto mb-1" />
              <p className="text-xs font-medium">Add More</p>
            </div>
          </button>
        </div>
      </Card>
    </Layout>
  );
}
